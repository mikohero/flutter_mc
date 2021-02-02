# flutter_mc
MC MAP - Motorcycle app in Flutter

I was very disappointed with action cameras. They were too expensive and only some stupid apps. I could not even program them. 
So I decided to find an action Camera with interface for software, so I can make my own setup in app and drive. 
Then I want to transfer data to web and later make webpage for showing data. 

When the user is driving on his MC, he can use a map and see where he is driving. Without internet and only location activated. This is pure phone based. 

Now the user can connect his action camera to the phone. I have chosen SJ4000 WIFI action camera, because this camera has a webservice point, where you can call all the actions from based on URLs. So this makes it possible to control the camera from the App. 

When user wants he can "mark" a specific location by pressing the MARK button - on the Map. This will take a lat, lng position and take an image from action camera. 
The image will be downloaded to the phone - to the download folder - to make it public accessible. 
The lat, lng strings and image-string-name will be saved in json format. Also in Download folder.
The user can take as many "mark"s as he wants during trip.
The user also has access to "Remove" button, which will remove last image+lat+lng. Then json file will be updated. He can remove until nothing left. 
When the trip is over all the images are on the phone and a json file with all the lat, lng, image-names. 
Now the user decouple the camera and connect to WIFI on his phone. Then on another screen he can first upload the json file and then all the images in the json file to the webserver. There are 2 buttons. 
On the webserver data will be saved to database. 

Some interesting ideas/problems to be solved:
1.
When user "mark". Then download image right away and save json file also. If camera stops working, then data is always updated. Done
2. 
Keep directory + image-name in app all the time using variables from startup of app. Faster. Done
3. 
User has forgotten to upload last trip. In Settings file - in app-dir - write if data is uploaded. If not - tell user - when he starts app. 
3.a. Then he has time to fix it before driving - or. Not done
3.b. He can wait with upload and another json file will be written. Number of upload must be in settings. not done
4.
When user upload - take one upload, then delete files. update settings. Not done. 

Testing
Now I have started to test. My Google maps did not move the camera when I was driving, so I updated the code with a specific call to that API part. 
Seems to be working now. 

Then I was driving and taking pictures, but my camera was not set perfect - very annoying. 
So I have made a new page, where I can take a picture with my helmet on and see it on my phone and see how the camera is aligned. Much better now.

Technology action cam for mc helmet and pocket:
SJ4000 WIFI cam: https://sjcam.com/product/sj4000/
Waterproof housing with powercable: https://www.aliexpress.com/item/33010136407.html?spm=a2g0o.search0302.0.0.125f18b2lRGuCt&algo_pvid=b9d16f47-aa04-44cc-8cd3-8ab0b1c7278d&algo_expid=b9d16f47-aa04-44cc-8cd3-8ab0b1c7278d-3&btsid=0bb0623316119436672255808e4430&ws_ab_test=searchweb0_0,searchweb201602_,searchweb201603_
20000 mAh powerbank: https://www.anker.com/products/variant/powercore-ii-20000/A1260011

Phone: 
Pocophone F1. 
USB charger from Bike. 
GPS phone holder For Honda: https://www.ebay.co.uk/itm/Honda-750D-Integra-Navigation-Mounting-GPS-Rack-Mount-2014-2020-/163283799497
Phone holder: https://www.mytrendyphone.dk/shop/forever-bh-110-universal-216247p.html?gclid=CjwKCAiAgc-ABhA7EiwAjev-jxEwDNaDaC6_OfLGxVV3ewgjZipR5kM0IpphmfG7iwCM1YQZQAj11BoCMsQQAvD_BwE




Contact me if you have any questions. mikommd@gmail.com, thanks
