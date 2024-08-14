# A list of useful packages for pixi.js

## Statistics

### pixi-stats
- install: `pnpm install pixi-stats`
- import: `import * as pxstat from 'pixi-stats'`
- usage:
```typescript
// add stats to app
this.pixiStats = pxstat.addStats(document, this.app);
PIXI.Ticker.shared.add(this.pixiStats.update, this.pixiStats, PIXI.UPDATE_PRIORITY.UTILITY);
```
