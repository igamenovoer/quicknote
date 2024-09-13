# How to deploy angular app to github pages

See this [guide](https://www.npmjs.com/package/angular-cli-ghpages).

And this official deployment [guide](https://angular.dev/tools/cli/deployment).

```bash
# first, install deployment plugin
ng add angular-cli-ghpages

# then in your angular app root, execute a command like this
# if anything goes wrong, delete the gh-pages branch
ng deploy --repo=git@github.com:igamenovoer/crystal-moment.git --base-href=/crystal-moment/
```
