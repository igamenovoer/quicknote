# How to Deploy the WAN 2.2 Model on Vertex AI

This guide provides a comprehensive overview of how to deploy and scale the training of the WAN 2.2 model on Google Cloud's Vertex AI.

## 1. Multi-GPU and Multi-Node Training on Vertex AI

### Is the current implementation sufficient?

The current training script is likely designed for a single machine and a single GPU. To take full advantage of Vertex AI's multi-GPU and multi-node capabilities, you will need to adapt your script for distributed training. Without these changes, your training job will only run on a single GPU on one machine, which will be slow and expensive for large models.

### Adapting for Distributed Training with `torch.distributed`

The standard way to perform distributed training in PyTorch is with the `torch.distributed` library. The most common strategy is `DistributedDataParallel` (DDP), which creates a copy of your model on each GPU and synchronizes the gradients during backpropagation.

Here's how you would typically modify your training script:

```python
import os
import torch
import torch.distributed as dist
from torch.nn.parallel import DistributedDataParallel as DDP
import torch.nn as nn

class ToyModel(nn.Module):
    def __init__(self):
        super(ToyModel, self).__init__()
        self.net1 = nn.Linear(10, 10)
        self.relu = nn.ReLU()
        self.net2 = nn.Linear(10, 5)

    def forward(self, x):
        return self.net2(self.relu(self.net1(x)))

def setup(rank, world_size):
    # Vertex AI automatically sets these environment variables
    os.environ['MASTER_ADDR'] = os.environ.get('MASTER_ADDR', 'localhost')
    os.environ['MASTER_PORT'] = os.environ.get('MASTER_PORT', '12355')
    dist.init_process_group("nccl", rank=rank, world_size=world_size)

def cleanup():
    dist.destroy_process_group()

def main():
    # In your main training function
    rank = int(os.environ.get('RANK', '0'))
    world_size = int(os.environ.get('WORLD_SIZE', '1'))

    setup(rank, world_size)

    # create model and move it to GPU with id rank
    model = ToyModel().to(rank)
    ddp_model = DDP(model, device_ids=[rank])

    # example training loop
    loss_fn = nn.MSELoss()
    optimizer = torch.optim.SGD(ddp_model.parameters(), lr=0.001)

    optimizer.zero_grad()
    outputs = ddp_model(torch.randn(20, 10).to(rank))
    labels = torch.randn(20, 5).to(rank)
    loss_fn(outputs, labels).backward()
    optimizer.step()

    cleanup()

if __name__ == '__main__':
    main()
```

When you submit a distributed training job to Vertex AI, it automatically configures the `MASTER_ADDR`, `MASTER_PORT`, `RANK`, and `WORLD_SIZE` environment variables on each node in the cluster. This makes the setup process much simpler.

## 2. Using Google Cloud Storage (GCS) for Data

### How to adapt the current implementation?

You have several options for accessing your training data from Google Cloud Storage. The best choice depends on your specific needs for simplicity versus performance.

### Method 1: `gcsfuse` (Recommended for Simplicity)

`gcsfuse` is a tool that mounts a GCS bucket as a local directory on your Vertex AI training instances. This is the easiest method to implement, as it requires almost no changes to your data loading code.

When you create your custom training job on Vertex AI, you can specify that you want to use `gcsfuse`. The GCS bucket will then be available at a path like `/gcs/your-bucket-name/`. You can then point your PyTorch `DataLoader` to this path as if it were a local directory.

### Method 2: `WebDataset` (Recommended for Performance)

For very large datasets, reading individual files from a `gcsfuse` mount can be slow. The `WebDataset` library is designed to address this by storing your data in `.tar` archives. This allows for much more efficient sequential reads from cloud storage.

While this approach requires you to preprocess your data into the `WebDataset` format, it can lead to significant performance improvements. You can find more information in the [official WebDataset documentation](https://github.com/webdataset/webdataset).

### Method 3: Direct GCS API (Advanced)

For the most control, you can use the `google-cloud-storage` client library to stream data directly from GCS within your PyTorch `Dataset`. This is the most complex option but can be useful for highly customized data loading pipelines.

## 3. Long-Term Strategy: PyTorch Lightning + DeepSpeed

### Should I consider adapting the script?

Yes, for long-term model development, especially if you plan to work across multiple cloud platforms, it is highly recommended that you adopt PyTorch Lightning and DeepSpeed.

### Benefits of PyTorch Lightning

PyTorch Lightning is a high-level framework that organizes your PyTorch code and abstracts away much of the boilerplate. This leads to:

*   **Cleaner Code:** Your code will be more organized and easier to read.
*   **Portability:** Your training script will be hardware-agnostic, making it easy to move between your local machine, GCP, Azure, and other platforms.
*   **Reduced Boilerplate:** Lightning handles the training loop, distributed training setup, and other details for you.

### Benefits of DeepSpeed

DeepSpeed is a library from Microsoft that excels at training massive models. Its key feature is the Zero Redundancy Optimizer (ZeRO), which can partition your model's parameters, gradients, and optimizer states across multiple GPUs and nodes. This allows you to train models that are far too large to fit into a single GPU's memory.

### The Power of a Combined Approach

PyTorch Lightning and DeepSpeed are designed to work together. You can use DeepSpeed as a "strategy" within Lightning to get the best of both worlds: the clean, portable code of Lightning and the powerful scaling of DeepSpeed.

Here's an example of how you would configure a PyTorch Lightning `Trainer` to use DeepSpeed:

```python
import pytorch_lightning as pl
import torch
import torch.nn as nn
from torch.utils.data import DataLoader, TensorDataset

class SimpleModel(pl.LightningModule):
    def __init__(self):
        super().__init__()
        self.layer = nn.Linear(32, 2)

    def forward(self, x):
        return self.layer(x)

    def training_step(self, batch, batch_idx):
        x, y = batch
        y_hat = self(x)
        loss = nn.functional.cross_entropy(y_hat, y)
        return loss

    def configure_optimizers(self):
        return torch.optim.Adam(self.parameters(), lr=0.02)

# Data
dataset = TensorDataset(torch.randn(100, 32), torch.randint(0, 2, (100,)))
train_loader = DataLoader(dataset)

model = SimpleModel()

# Configure the DeepSpeed strategy
deepspeed_strategy = pl.strategies.DeepSpeedStrategy(
    stage=3,
    offload_optimizer=True,
    offload_parameters=True,
)

trainer = pl.Trainer(
    accelerator="gpu",
    devices="auto",
    strategy=deepspeed_strategy,
)

trainer.fit(model, train_loader)
```

By adopting this combined approach, you will have a highly scalable and portable training pipeline that can be easily adapted to different cloud environments and model architectures.

## 4. Implementation Steps for Vertex AI

This section provides the specific code and configuration you'll need to run your training job on Vertex AI.

### Step 1: Create `accelerate_config_vertex_ai.yaml`

Create a new file named `accelerate_config_vertex_ai.yaml` with the following content. This configuration is optimized for multi-node training on Vertex AI.

```yaml
compute_environment: GCP_VERTEX_AI
deepspeed_config:
  gradient_accumulation_steps: 1
  offload_optimizer_device: cpu
  offload_param_device: cpu
  zero3_init_flag: false
  zero_stage: 2
distributed_type: DEEPSPEED
downcast_bf16: 'no'
machine_rank: 0
main_training_function: main
mixed_precision: bf16
num_machines: 2 # Example: 2 nodes
num_processes: 16 # Example: 2 nodes * 8 GPUs/node
rdzv_backend: static
same_network: true
use_cpu: false
```

**Key Changes:**

*   `compute_environment`: Set to `GCP_VERTEX_AI` to enable `accelerate`'s automatic configuration for Vertex AI.
*   `num_machines`: Set to the number of nodes in your training cluster.
*   `num_processes`: Set to `num_machines` multiplied by the number of GPUs per machine.

### Step 2: Modify the Launch Scripts

You will need to modify your `.sh` scripts to use the new `accelerate` config and to accept a GCS path for the dataset.

**Example: `Wan2.2-T2V-A14B-vertexai.sh`**

```bash
#!/bin/bash

# Accept GCS path as an argument
DATASET_GCS_PATH=$1

accelerate launch --config_file examples/wanvideo/model_training/full/accelerate_config_vertex_ai.yaml examples/wanvideo/model_training/train.py \
  --dataset_base_path ${DATASET_GCS_PATH} \
  --dataset_metadata_path ${DATASET_GCS_PATH}/metadata.csv \
  --height 480 \
  --width 832 \
  --num_frames 49 \
  --dataset_repeat 100 \
  --model_id_with_origin_paths "Wan-AI/Wan2.2-T2V-A14B:high_noise_model/diffusion_pytorch_model*.safetensors,Wan-AI/Wan2.2-T2V-A14B:models_t5_umt5-xxl-enc-bf16.pth,Wan-AI/Wan2.2-T2V-A14B:Wan2.1_VAE.pth" \
  --learning_rate 1e-5 \
  --num_epochs 2 \
  --remove_prefix_in_ckpt "pipe.dit." \
  --output_path "/gcs/your-output-bucket/models/train/Wan2.2-T2V-A14B_high_noise_full" \
  --trainable_models "dit" \
  --max_timestep_boundary 0.417 \
  --min_timestep_boundary 0
```

**Key Changes:**

*   The script now accepts the GCS path as a command-line argument.
*   The `--config_file` argument points to your new `accelerate_config_vertex_ai.yaml`.
*   The `--output_path` is set to a GCS path.

### Step 3: Create a `Dockerfile`

Create a `Dockerfile` in the root of your project to define the training environment.

```dockerfile
FROM us-docker.pkg.dev/vertex-ai/training/pytorch-gpu.1-13.py310:latest

# Install dependencies
COPY . /workspace
WORKDIR /workspace
RUN pip install -r requirements.txt

# Set up gcsfuse
RUN apt-get update && apt-get install -y lsb-release && \
    echo "deb https://packages.cloud.google.com/apt gcsfuse-$(lsb_release -c -s) main" | tee /etc/apt/sources.list.d/gcsfuse.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update && apt-get install -y gcsfuse

# Set entrypoint
ENTRYPOINT ["/bin/bash"]
```

### Step 4: Create a Submission Script

Finally, create a Python script to submit the training job to Vertex AI.

**`submit_vertex_ai_job.py`**

```python
from google.cloud import aiplatform

def main():
    aiplatform.init(project="your-gcp-project-id", location="us-central1")

    job = aiplatform.CustomJob(
        display_name="wan2.2-training",
        worker_pool_specs=[
            {
                "machine_spec": {
                    "machine_type": "a2-highgpu-8g",
                    "accelerator_type": "NVIDIA_TESLA_A100",
                    "accelerator_count": 8,
                },
                "replica_count": 2, # Should match num_machines in accelerate config
                "container_spec": {
                    "image_uri": "gcr.io/your-gcp-project-id/wan2.2-training:latest",
                    "command": [
                        "bash",
                        "examples/wanvideo/model_training/full/Wan2.2-T2V-A14B-vertexai.sh",
                    ],
                    "args": [
                        "/gcs/your-dataset-bucket/"
                    ],
                },
            }
        ],
        gcs_bucket="your-staging-bucket",
    )

    job.run()

if __name__ == "__main__":
    main()
```

## 5. Refactoring to PyTorch Lightning

For a more robust and portable solution, you can refactor your training script to use PyTorch Lightning. This will involve creating a `LightningModule` to encapsulate your model and training logic, and a `LightningDataModule` to handle your data loading.

### A Note on Hugging Face `accelerate`

You'll notice that this refactoring removes the need for the `accelerate launch` command and the associated `.yaml` configuration file. This is because PyTorch Lightning and Hugging Face `accelerate` are generally alternative solutions to the same problem.

*   **`accelerate`** is a library that adds a lightweight layer on top of a standard PyTorch training loop to make it run in a distributed environment.
*   **PyTorch Lightning** is a more comprehensive framework that abstracts away the entire training loop into the `Trainer` object. It has its own internal system of "Strategies" (e.g., `DeepSpeedStrategy`, `DDPStrategy`) to manage distributed training.

When you adopt PyTorch Lightning, the `Trainer` and its `strategy` argument take over the responsibilities that `accelerate` was previously handling. You are essentially swapping one distributed training abstraction for another, more structured one.

### Step 1: Create the `WanLightningModule`

The `LightningModule` will contain the logic from your existing `WanTrainingModule`.

```python
import pytorch_lightning as pl
from diffsynth.pipelines.wan_video_new import WanVideoPipeline

class WanLightningModule(pl.LightningModule):
    def __init__(self, hparams):
        super().__init__()
        self.save_hyperparameters(hparams)

        # Load models
        model_configs = self.parse_model_configs(
            self.hparams.model_paths, self.hparams.model_id_with_origin_paths
        )
        # It's best practice to initialize the model on the CPU.
        # The PyTorch Lightning Trainer will automatically move it to the correct GPU device.
        self.pipe = WanVideoPipeline.from_pretrained(
            torch_dtype=torch.bfloat16, device="cpu", model_configs=model_configs
        )

### How Lightning Manages Device Placement

You might wonder how the `Trainer` knows what to move to the GPU. Here's how it works:

1.  **The `LightningModule` is a `torch.nn.Module`:** When you assign a module (like `self.pipe`) as an attribute of the `LightningModule`, its parameters are automatically registered.
2.  **The `Trainer` Moves the Module:** When training begins, the `Trainer` calls `.to(device)` on the entire `LightningModule`. This single call recursively moves all registered sub-modules and their parameters (including `self.pipe`) to the correct GPU.
3.  **Data is Moved Automatically:** The `Trainer` also automatically moves each data batch from your `DataLoader` to the correct device before passing it to `training_step`.

This is why you initialize on the "cpu"—you are correctly delegating the responsibility of device management to the framework.

        # Training mode
        self.switch_pipe_to_training_mode(
            self.pipe, self.hparams.trainable_models,
            self.hparams.lora_base_model, self.hparams.lora_target_modules, self.hparams.lora_rank,
            lora_checkpoint=self.hparams.lora_checkpoint,
        )

    def training_step(self, batch, batch_idx):
        # The forward pass and loss calculation from your original script
        inputs = self.forward_preprocess(batch)
        models = {name: getattr(self.pipe, name) for name in self.pipe.in_iteration_models}
        loss = self.pipe.training_loss(**models, **inputs)
        self.log("train_loss", loss)
        return loss

    def configure_optimizers(self):
        # Configure your optimizer here
        optimizer = torch.optim.AdamW(self.parameters(), lr=self.hparams.learning_rate)
        return optimizer

    def forward_preprocess(self, data):
        # This is the same forward_preprocess method from your WanTrainingModule
        # ... (copy the method here) ...
        pass

    # Helper methods from WanTrainingModule
    def parse_model_configs(self, model_paths, model_id_with_origin_paths):
        # ... (copy the method here) ...
        pass

    def switch_pipe_to_training_mode(self, pipe, trainable_models, lora_base_model, lora_target_modules, lora_rank, lora_checkpoint):
        # ... (copy the method here) ...
        pass
```

### Step 2: Create the `WanDataModule`

The `LightningDataModule` will encapsulate your dataset and dataloaders.

```python
from diffsynth.trainers.unified_dataset import UnifiedDataset

class WanDataModule(pl.LightningDataModule):
    def __init__(self, hparams):
        super().__init__()
        self.save_hyperparameters(hparams)

    def setup(self, stage=None):
        self.dataset = UnifiedDataset(
            base_path=self.hparams.dataset_base_path,
            metadata_path=self.hparams.dataset_metadata_path,
            repeat=self.hparams.dataset_repeat,
            data_file_keys=self.hparams.data_file_keys.split(","),
            main_data_operator=UnifiedDataset.default_video_operator(
                base_path=self.hparams.dataset_base_path,
                max_pixels=self.hparams.max_pixels,
                height=self.hparams.height,
                width=self.hparams.width,
                num_frames=self.hparams.num_frames,
            ),
        )

    def train_dataloader(self):
        return torch.utils.data.DataLoader(
            self.dataset,
            batch_size=self.hparams.batch_size,
            num_workers=self.hparams.num_workers,
        )
```

### Step 3: Update the Training Script

Finally, update your main training script to use the new Lightning modules.

```python
import pytorch_lightning as pl
from argparse import ArgumentParser

def main(hparams):
    model = WanLightningModule(hparams)
    datamodule = WanDataModule(hparams)

    deepspeed_strategy = pl.strategies.DeepSpeedStrategy(
        stage=3,
        offload_optimizer=True,
        offload_parameters=True,
    )

    trainer = pl.Trainer(
        accelerator="gpu",
        devices="auto",
        strategy=deepspeed_strategy,
        max_epochs=hparams.num_epochs,
    )

    trainer.fit(model, datamodule)

if __name__ == "__main__":
    parser = ArgumentParser()
    # Add all your command-line arguments to the parser
    # ...
    args = parser.parse_args()
    main(args)
```
