# flutter_mc
MC MAP - Motorcycle app in Flutter
When the user is driving on his MC, he can use a map and see where he is driving. Without internet and only location activated. This is pure phone based. 

Now the user can connect his action camera to the phone. I have chosen SJ4000 WIFI action camera, because this camera has a webservice point, where you can call all the actions from based on URLs. So this makes it possible to control the camera from the App. 

When he wants he can "mark" a specific location by pressing the MARK button - on the Map. This will take a lat, lng position and take an image from action camera. 
The image will be downloaded to the phone - to the download folder - to make it public accessible. 
The lat, lng strings and image-string-name will be saved in json format. Also in Download folder.
The user can take as many "mark"s as he wants. 
The user also has access to "Remove" button, which will remove last image+lat+lng. Then json file will be updated. He can remove until nothing left. 
When the trip is over all the images are on the phone and a json file with all the lat, lng, image-names. 
Now the user decouple the camera and connect to WIFI on his phone. Then on another screen he can upload the json file and all the images in the json file to the webserver.
At the webserver data will be saved to database. 

Some interesting ideas/problems to be solved:
1.
When user "mark". Then download image right away and save json file also. If camera stops working, then data is always updated. 
2. 
Keep directory + image-name in app all the time using variables from startup of app. Faster. 
3. 
User has forgotten to upload last trip. In Settings file - in app-dir - write if data is uploaded. If not - tell user - when he starts app. 
3.a. Then he has time to fix it before driving - or
3.b. He can wait with upload and another json file will be written. Number of upload must be in settings
4.
When user upload - take one upload, then delete files. update settings. 


Contact me if you have any questions. mikommd@gmail.com, thanks
