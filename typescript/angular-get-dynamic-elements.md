# How to get the dyanmically generated DOM elements?

see [this](https://stackoverflow.com/questions/70138110/how-to-get-a-dynamically-generated-element-in-angular-without-queryselector)

In your template

```html
<div
  #myToasts
  class="toast default"
  [ngClass]="{ 'slide-out-animation': t.TimeLeft < 1 }"
>
```

In your component

```typescript
@ViewChildren('myToasts') myToasts: QueryList<ElementRef>;

ngAfterViewInit() {
  this.myToasts.changes.subscribe(toasts => {
    console.log('Array length: ', toasts.length);
    console.log('Array of elements: ', toasts.toArray())
  })
}
```
