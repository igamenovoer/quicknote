# How to test angular components against firefox?

Angular's unit test is handled by Karma, so you need to configure through karma

First, ask for the karma config
```bash
ng generate config karma
```

Then, in `karma.conf.js`, add the following line
```js
  plugins: [
  ...
    require('karma-firefox-launcher'),  //add this
  ...
  ],
```

If you do not have `karma-firefox-launcher`, install it with `npm` or `pnpm`
```bash
pnpm install karma-firefox-launcher --save-dev
```

Then, start testing with
```bash
# browser name is CASE SENSITIVE!
ng test --browsers=Firefox
```
