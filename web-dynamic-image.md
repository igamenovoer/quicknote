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
