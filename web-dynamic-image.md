# How to display dynamic image

## Using blob
see [how to use js to display a blob](https://stackoverflow.com/questions/7650587/using-javascript-to-display-a-blob)

```javascript
// get image as binary data
var xhr = new XMLHttpRequest();
xhr.open("GET", "http://localhost/image.jpg");
xhr.responseType = "blob";
xhr.onload = response;
xhr.send();

// create object url and set it to <img>
function response(e) {
   var urlCreator = window.URL || window.webkitURL;
   var imageUrl = urlCreator.createObjectURL(this.response);
   document.querySelector("#image").src = imageUrl;
}
```

in html, create an empty image to hold the data

```html
<img id="image"/>
```

this is another js example

```javascript
var myImage = document.querySelector('img');

fetch('flowers.jpg').then(function(response) {
  return response.blob();
}).then(function(myBlob) {
  var objectURL = URL.createObjectURL(myBlob);
  myImage.src = objectURL;
});
```

## Using OffscreenCanvas
Offscreen canvas allows one to dynamically generate images (potentially in another thread), and then blit it to the visible canvas.

See the [official doc](https://developer.mozilla.org/en-US/docs/Web/API/OffscreenCanvas)

Suppose you have 2 visible canvases

```html
<canvas id="one"></canvas> <canvas id="two"></canvas>
```

Then you can use offscreen canvas to manipulate them

```javascript
const one = document.getElementById("one").getContext("bitmaprenderer");
const two = document.getElementById("two").getContext("bitmaprenderer");

const offscreen = new OffscreenCanvas(256, 256);
const gl = offscreen.getContext("webgl");

// Perform some drawing for the first canvas using the gl context
const bitmapOne = offscreen.transferToImageBitmap();
one.transferFromImageBitmap(bitmapOne);

// Perform some more drawing for the second canvas
const bitmapTwo = offscreen.transferToImageBitmap();
two.transferFromImageBitmap(bitmapTwo);
```

Another way to use it is the control a visible canvas with an OffscreenCanvas

```javascript
const htmlCanvas = document.getElementById("canvas");
const offscreen = htmlCanvas.transferControlToOffscreen();

const worker = new Worker("offscreencanvas.js");
worker.postMessage({ canvas: offscreen }, [offscreen]);

// in offscreencanvas.js
onmessage = (evt) => {
  const canvas = evt.data.canvas;
  const gl = canvas.getContext("webgl");

  function render(time) {
    // Perform some drawing using the gl context
    requestAnimationFrame(render);
  }
  requestAnimationFrame(render);
};
```

## Refreshing a cached image
see [how to replace a cached image](https://stackoverflow.com/questions/321865/how-to-clear-or-replace-a-cached-image)

see [how to force the browser not to cache images](https://stackoverflow.com/questions/126772/how-to-force-a-web-browser-not-to-cache-images/70954519#70954519)

The trick is append a query to the url.

Using last-modified timestamp

```html
<img src="image.jpg?lastmod=12345678" />
```

or using timestamp

```html
<img src="picture.jpg?1222259157.415" alt="" />
```

Where "1222259157.415" is the current time on the server.
Generate time by Javascript with `performance.now()` or by Python with `time.time()`

## Using base64 content as src
see [how to display base64 image](https://stackoverflow.com/questions/8499633/how-to-display-base64-images-in-html)

convert your binary encoded image data into base64, with appropriate mime type, you can use it as src

```html
<div>
  <p>Taken from wikpedia</p>
  <img src="data:image/png;base64, iVBORw0KGgoAAAANSUhEUgAAAAUA
    AAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO
        9TXL0Y4OHwAAAABJRU5ErkJggg==" alt="Red dot" />
</div>
```

Note, if you are dealing with binary image data, you can convert bytes to `Uint8Array` in js, and then process it.
see [this post](https://stackoverflow.com/questions/28482359/binary-stream-to-uint8array-javascript)

```javascript
var bytes = Object.keys(stream).length;
var myArr = new Uint8Array(bytes)

for(var i = 0; i < bytes; i++){
    myArr[i] = stream[i].charCodeAt(0);
}
```
