# How to control the video-to-canvas update rate?

```typescript
  private _register_frame_update_events() {
    const eps = this.options.frame_time_epsilon;

    // NOTE: for some unknown reason, the debounceTime does NOT work as expected
    // it will sometimes skip the last frame, making the canvas and video out of sync
    // maybe due to its async scheduling.
    const sub_frame_update = this._frameUpdateRequest$
      .pipe(distinctUntilChanged((x, y) => Math.abs(x.frameTimeMs - y.frameTimeMs) < eps))
      // .pipe(debounceTime(this.options.frame_update_event_interval_ms)) // this does not work as expected
      .pipe(throttleTime(this.options.frame_update_event_interval_ms, undefined, { leading: true, trailing: true }))
      .subscribe((evt) => {
        console.log(`frame update request: ${evt.frameTimeMs} ms`);

        // draw the frame to the canvas
        if (this.options.use_frame_canvas) {
          this._update_frame_canvas();
        }

        // notify others
        this.frameUpdated$.next(evt);
      });
    this._videoElementSubscriptions.push(sub_frame_update);
  }
```
