# A list of useful packages for pixi.js

## Statistics

### [pixi-stats](https://www.npmjs.com/package/pixi-stats)
- install: `pnpm install pixi-stats`
- import: `import * as pxstat from 'pixi-stats'`
- usage:
```typescript
  async init_pixi() {
    this.app = new PIXI.Application();
    await this.app.init({ background: '#1099bb', width: 640, height: 480 });
    document.body.appendChild(this.app.canvas);
    this.isPixiInitialized = true;

    // add stats to app
    this.pixiStats = pxstat.addStats(document, this.app);
    PIXI.Ticker.shared.add(this.pixiStats.update, this.pixiStats, PIXI.UPDATE_PRIORITY.UTILITY);
}
```
