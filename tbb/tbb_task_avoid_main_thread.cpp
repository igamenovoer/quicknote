// demostrate how to avoid a task to be executed in main thread and block it
#include <tbb/tbb.h>
#include <chrono>
#include <thread>
#include <atomic>
#include <random>
#include <spdlog/spdlog.h>
#include <fmt/format.h>
#include <fmt/color.h>

int do_works_compare_strategy(int num_worker_threads, int num_tasks);

int main()
{
    // do_works_originated_from_custom_thread(2, 100);
    do_works_compare_strategy(3, 100);
    return 0;
}

int do_works_compare_strategy(int num_worker_threads, int num_tasks)
{
    std::thread::id main_thread_id = std::this_thread::get_id();
    std::atomic<int> task_counter(0);

    auto execute_task = [&main_thread_id, &task_counter](const std::string &strategy) {
        if (std::this_thread::get_id() == main_thread_id) {
            spdlog::error("[{}] Task is running on the main thread!", strategy);
            throw std::runtime_error("Task is running on the main thread");
        }

        int task_id = ++task_counter;
        uint64_t thread_id = static_cast<uint64_t>(std::hash<std::thread::id>{}(std::this_thread::get_id()));
        std::random_device rd;
        std::mt19937 gen(rd());
        std::uniform_int_distribution<> dis(20, 50);
        int wait_ms = dis(gen);
        std::this_thread::sleep_for(std::chrono::milliseconds(wait_ms));
    };

    auto run_strategy = [&](const std::string &strategy, const std::function<void()> &strategy_func) {
        spdlog::info("Starting strategy: {}", strategy);
        task_counter.store(0);
        try {
            strategy_func();
        } catch (const std::exception &e) {
            spdlog::error("Exception in strategy {}: {}", strategy, e.what());
        }
        spdlog::info("Completed strategy: {}", strategy);
    };

    //! Strategy 1: Create task group in main thread, submit tasks to the group and wait
    run_strategy("Strategy 1", [&]() {
        spdlog::info("Strategy 1: Creating task group in main thread");
        tbb::task_group group;
        for (int i = 0; i < num_tasks; ++i) {
            group.run([&]() { execute_task("Strategy 1"); });
        }
        spdlog::info("Strategy 1: Waiting for all tasks to complete");
        group.wait();
        spdlog::info("Strategy 1: All tasks completed");
    });

    //! Strategy 2: Create a task arena and task group in main thread, use task arena's execute to add tasks into group, and wait the group in main thread
    run_strategy("Strategy 2", [&]() {
        spdlog::info("Strategy 2: Creating task arena with {} threads", num_worker_threads);
        tbb::task_arena arena(num_worker_threads);
        spdlog::info("Strategy 2: Creating task group");
        tbb::task_group group;
        spdlog::info("Strategy 2: Executing task submission in arena");
        arena.execute([&]() {
            for (int i = 0; i < num_tasks; ++i) {
                group.run([&]() { execute_task("Strategy 2"); });
            }
        });
        spdlog::info("Strategy 2: Waiting for all tasks to complete in main thread");
        group.wait();
        spdlog::info("Strategy 2: All tasks completed");
    });

    //! Strategy 3: Like Strategy 2, but wait the group in task arena's execute
    run_strategy("Strategy 3", [&]() {
        spdlog::info("Strategy 3: Creating task arena with {} threads", num_worker_threads);
        tbb::task_arena arena(num_worker_threads);
        spdlog::info("Strategy 3: Creating task group");
        tbb::task_group group;
        spdlog::info("Strategy 3: Executing task submission and wait in arena");
        arena.execute([&]() {
            for (int i = 0; i < num_tasks; ++i) {
                group.run([&]() { execute_task("Strategy 3"); });
            }
            spdlog::info("Strategy 3: Waiting for all tasks to complete within arena");
            group.wait();
        });
        spdlog::info("Strategy 3: All tasks completed");
    });

    //! Strategy 4: Create a my_worker_thread in main thread, and do the above tests inside the my_worker_thread
    run_strategy("Strategy 4", [&]() {
        spdlog::info("Strategy 4: Creating worker thread");
        std::thread my_worker_thread([&]() {
            spdlog::info("Strategy 4: Worker thread started");

            //! Strategy 4a: Create task group in worker thread
            spdlog::info("Strategy 4a: Creating task group in worker thread");
            tbb::task_group group_a;
            for (int i = 0; i < num_tasks; ++i) {
                group_a.run([&]() { execute_task("Strategy 4a"); });
            }
            spdlog::info("Strategy 4a: Waiting for all tasks to complete");
            group_a.wait();
            spdlog::info("Strategy 4a: All tasks completed");

            //! Strategy 4b: Create task arena and group in worker thread, execute in arena
            spdlog::info("Strategy 4b: Creating task arena with {} threads", num_worker_threads);
            tbb::task_arena arena_b(num_worker_threads);
            spdlog::info("Strategy 4b: Creating task group");
            tbb::task_group group_b;
            spdlog::info("Strategy 4b: Executing task submission in arena");
            arena_b.execute([&]() {
                for (int i = 0; i < num_tasks; ++i) {
                    group_b.run([&]() { execute_task("Strategy 4b"); });
                }
            });
            spdlog::info("Strategy 4b: Waiting for all tasks to complete in worker thread");
            group_b.wait();
            spdlog::info("Strategy 4b: All tasks completed");

            //! Strategy 4c: Create task arena and group in worker thread, execute and wait in arena
            spdlog::info("Strategy 4c: Creating task arena with {} threads", num_worker_threads);
            tbb::task_arena arena_c(num_worker_threads);
            spdlog::info("Strategy 4c: Creating task group");
            tbb::task_group group_c;
            spdlog::info("Strategy 4c: Executing task submission and wait in arena");
            arena_c.execute([&]() {
                for (int i = 0; i < num_tasks; ++i) {
                    group_c.run([&]() { execute_task("Strategy 4c"); });
                }
                spdlog::info("Strategy 4c: Waiting for all tasks to complete within arena");
                group_c.wait();
            });
            spdlog::info("Strategy 4c: All tasks completed");
        });
        spdlog::info("Strategy 4: Joining worker thread");
        my_worker_thread.join();
        spdlog::info("Strategy 4: Worker thread joined");
    });

    //! Conclusion
    spdlog::info("Conclusion:");
    spdlog::info("Strategies that can avoid task execution in the main thread:");
    spdlog::info("- Strategy 2: Submit tasks to task group inside arena execute, and wait the task group in main thread");
    spdlog::info("- Strategy 4: Custom worker thread, do any way you want, it never touches the main thread");
    spdlog::info("");
    spdlog::info("Strategies that do not work (may execute tasks in the main thread):");
    spdlog::info("- Strategy 1: Submit tasks to task group inside main thread and wait in main thread, without task arena");
    spdlog::info("- Strategy 3: Submit tasks to task group inside task arena's execute, and wait task group in arena execute");
    spdlog::info("");
    spdlog::info("The most effective strategy is Strategy 4, which involves:");
    spdlog::info("• Creating a custom worker thread");
    spdlog::info("• Performing all task management within the worker thread");
    spdlog::info("• Using task arenas and groups within the worker thread");
    spdlog::info("• Joining the worker thread from the main thread");
    spdlog::info("");
    spdlog::info("This approach ensures complete isolation of task execution from the main thread,");
    spdlog::info("providing the most robust solution for avoiding main thread involvement in task processing.");

    return 0;
}
