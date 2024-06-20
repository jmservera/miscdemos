// wwwroot/script.js
document.getElementById('myButton').addEventListener('click', function() {
    document.getElementById('overlay').style.display = 'block';
    fetch('/colorandpet')
        .then(response => response.json())
        .then(data => {
            document.body.style.backgroundColor = data.rgb;
            document.getElementById('myImage').style.backgroundColor= "rgba(0, 0, 0, 0.5)";
            if(data.imageUrl)
                document.getElementById('myImage').src = data.imageUrl;
            document.getElementById('myText').textContent = data.summary;
            document.getElementById('overlay').style.display = 'none';
        })
        .catch(error => {
            console.error('Error:', error);
            document.getElementById('overlay').style.display = 'none';
        });
});