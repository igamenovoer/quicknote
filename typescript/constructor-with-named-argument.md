# How to define a class whose constructor can accept named argument?

see [this](https://constantsolutions.dk/2023/08/03/named-constructors-in-typeScript-constructing-classes-or-objects-using-dart-style/)

It depends on `class-transformer` npm package, install it first.

```bash
npm install class-transformer
```

Then define a base class like this
```typescript
import { plainToInstance } from "class-transformer";

/**
 * @description Base class whose child can be constructed with named arguments
 * see https://constantsolutions.dk/2023/08/03/named-constructors-in-typeScript-constructing-classes-or-objects-using-dart-style/
 * @example
 * class Person extends NamedConstructable<Person> {
 *    name: string;
 *    age: number;
 * }
 * // then you can create an instance of Person like this
 * const person = new Person({name: 'John', age: 30});
 */
export class NamedConstructable<T> {
    constructor(obj: Partial<T> = {}) {
        Object.assign(this, plainToInstance(this.constructor as any, obj));
    }
}
```

Then you can derive from this base

```typescript
import { NamedConstructable } from "../named-constructable";

/**
 * @description metadata of a video, names follows ffmpeg conventions
 */
export class VideoInfo extends NamedConstructable<VideoInfo> {
    codec_name: string = '';
    codec_tag: string = '';  //see ffprobe
    width: number = 0;
    height: number = 0;
    pix_fmt: string = '';
    frame_rate: number = 0; //fps, ffprobe::r_frame_rate
    time_base: number = 0;  //ffprobe::time_base
    duration_sec: number = 0;   //seconds, ffprobe::duration
    num_frames: number = 0; //number of frames, ffprobe::nb_frames, may be missing
}

// it allows you to create object like this
let x = new VideoInfo({codec_name: 'h264', width: 800, height: 600});
```
