# Branch Challenge
## Task: Integrate Branch in iOS app
```Created as a part of the interview process for Support Engineer role```
### Objective:
* Integrate the Branch SDK
	* Follow the SDK integration steps outline [here](https://docs.branch.io/pages/apps/ios/)
* Set up custom event tracking, link creation, and content sharing
	* Track that the user visited the monster edit page (call event "monster_edit") on the MonsterCreatorViewController
	* Track that the user visited the monster view page (call event "monster_view") on the MonsterViewerViewController. This time, include state (as specified in `self.monsterMetadata`)
	* Inside `viewDidLoad`, get a shortURL with params, using the params provided by `prepareBranchDict`. Put that URL into self.textURL's text, and be sure to move the `[self.progressBar hide];` inside the completionhandler
	* Inside `cmdMessageClick`, get a short URL with params. Get the params from `prepareBranchDict`, set the channel to be "sms", and make sure that you use an asynchronous method.
	* Only present the smsViewController if there is no error in getting the Branch link. If you are using the simulator, set a break point when that button is activated, and ensure that you return a Branch URL. Save it for later.

#### Author:
* Austin Harshberger