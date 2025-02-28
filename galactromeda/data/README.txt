INTRODUCTION
============
This archive was generated at the request of the following user:
- @username at the time the archive was generated: galactromeda
- Account ID: 205543370

The easiest way to navigate your archive is to open the HTML renderer in a desktop web browser by double clicking the “Your archive” file included in the main folder once the archive is unzipped.

Note that the HTML renderer only works if the archive is less than 50GB. Also note that the HTML renderer only includes a subset of the data included in the archive. To see all the data included in the archive, please navigate the JSON files located in the “data” folder.

The data folder consists of machine-readable JSON files with a .js extension containing information associated with this account. We’ve included the information we believe is most relevant and useful, including profile information, Tweets, Direct Messages, Moments, images, videos and GIFs attached to Tweets, Direct Messages or Moments, followers, following, address book, Lists created, a member of, or subscribed to, interest and demographic information that we have inferred, information about ads seen or engaged with on Twitter, and more.

Each file contains detailed information about that category of data. To see this information, simply double click on one of the JSON files. Note that some information, such as the media shared via Direct Messages, is included in a folder instead of a JSON file. Separately, also note that some files may not contain any information if your account is not associated with any of the data they cover.

The information contained in this archive reflects the state of the account at the time when the archive was created.

FILE DESCRIPTIONS
=================
=== SENSORY INFORMATION ===
(Audio, electronic, visual, and similar information)

audio-video-calls-in-dm-recipient-sessions.js
This JSON file contains the metadata of audio or video calls received in a one-to-one Direct Messages conversation.
- createdAt: Date and time when the call session was created.
- publishedAt: Date and time when the peer to peer connection was successfully established between the two participants.
- startedAt: Date and time when the call session was created. This is updated to publishedAt if the peer to peer connection successfully establishes.
- lastPingedAt: Date and time of the last time the user’s client sent a ping to X servers during the pendency of the call session.
- endedAt: Date and time when the call session was ended.
- endReason: "MISSED"    The recipient missed the call.
"DECLINED"  The recipient declined the call.
"HUNG_UP"   the recipient ended the call by hanging up.
"TIMED_OUT" The call was ended due to a non responsive participant.

- hostBroadcastID: Unique id for the broadcast object associated with the call.
----------------------
audio-video-calls-in-dm.js
This JSON file contains the metadata of audio or video calls initiated in a one-to-one Direct Messages conversation.
- broadcast: Broadcast object associated with the call. id represents a Unique id for the broadcast object associated with the call. inviteesTwitter represents a list of X user id recipients of the call. createdAt represents the Date and time when the call was initiated. updatedAt represents the Date and time of the last broadcast update. endAt  represents the Date and time when the call was ended by one of the participants.

- sessions: List of participant sessions metadata that belong to this call. The product set item can be either a product or a product group. twitterUserID represents the session owner user id. hostBroadcastID represents the unique id for the broadcast object where this session belongs to. endReason represents the reason why the call ended.
  "CANCELED"  The caller left before callee joined within the first 30sec of the call.
  "MISSED"    The recipient missed the call.
  "DECLINED"  The recipient declined the call.
  "HUNG_UP"   The caller or recipient ended the call by hanging up.
  "TIMED_OUT" The call was ended due to a non responsive participant.
createdAt represents the Date and time when the call session was created. publishedAt represents the Date and time when the peer to peer session was successfully established between the two participants. startedAt represents the Date and time when the call session was created. This is updated to publishedAt if the peer to peer session successfully establishes.
----------------------
community_tweet_media
Folder of images, videos, and/or gifs shared in the account’s Tweets that are posted in Communities. Note: this folder does not include media hosted on other platforms but linked on Twitter (for example, Youtube videos).

If Tweets have been posted in Communities and there is associated media, you can match the media to the community_tweet data file. The filename for each media file in the community_tweet_media folder contains a numerical ID that corresponds to a Community Tweet in the community_tweet file. By searching the community_tweet file for the numeric portion of the filename of the media, you can find the corresponding Community Tweet.

If your production includes a community_tweet file and did not include a community_tweet_media folder, this is because there was no media associated with the community_tweet file.
----------------------
deleted_tweets_media
Folder of images, videos, and/or gifs shared in the account’s deleted Tweets. Note: this folder does not include media hosted on other platforms but linked on Twitter (for example, Youtube videos).

This folder contains media for Tweets that have been deleted in the last 14 days, but have not yet been deleted from our production systems as these systems have a deletion schedule of approximately 14 days.

If Tweets have been produced and there is associated media, you can match the media to the deleted-tweets data file. The filename for each media file in the deleted_tweets_media folder contains a numerical ID that corresponds to a Tweet in the deleted-tweets file. By searching the deleted-tweets file for the numeric portion of the filename of the media, you can find the corresponding Tweet.

If your production includes a deleted-tweets file and did not include a deleted_tweets_media folder, this is because there was no media associated with the deleted-tweets file.
----------------------
direct_messages_group_media
Folder of images, videos and gifs shared in the account’s Direct Message group conversations. Note:this folder does not include media hosted on other platforms but linked on Twitter (for example, YouTube videos).

If Group Direct Messages (Group DMs) have been produced and there is associated media, you can match the media to the Group DM data file. The filename for each media file in the direct_messages_group_media folder contains a numerical ID that corresponds to a Group DM in the direct-messages-group file. By searching the direct-messages-group file for the numeric portion of the filename of the media, you can find the corresponding Group DM.

If your production includes a direct-messages-group file and did not include a direct_messages_group_media folder, this is because there was no media associated with the direct-messages-group file.
----------------------
direct_messages_media
Folder of images, videos and gifs shared in the account’s one-on-one Direct Message conversations. Note: this folder does not include media hosted on other platforms but linked on Twitter (for example, YouTube videos).

If Direct Messages (DMs) have been produced and there is associated media, you can match the media to the DM data file. The filename for each media file in the direct_messages_media folder contains a numerical ID that corresponds to a DM in the direct-messages file. By searching the direct-messages file for the numeric portion of the filename of the media, you can find the corresponding DM.

If your production includes a direct-messages file and did not include a direct_messages_media folder, this is because there was no media associated with the direct-messages file.
----------------------
moments_media
Folder of images, videos and gifs uploaded through Twitter’s photo hosting service for Tweets that have been added as Moment cover media. This media may or may not have been originally posted by the account that created the Moment. Note: this folder does not include media hosted on other platforms but linked on Twitter (for example, YouTube videos)
----------------------
moments_tweets_media
Folder of images, videos and gifs uploaded through Twitter’s photo hosting service for Tweets that have been included in a Moment. This media may or may not have been originally posted by the account that created the Moment. Note: this folder does not include media hosted on other platforms but linked on Twitter (for example, YouTube videos)
----------------------
periscope-expired-broadcasts.js
- broadcastIds: A list of the broadcast IDs posted by the shell account that have expired and cannot be encoded.
- reason: Explanation of why broadcast replay files are unavailable (hard-coded).
----------------------
periscope_broadcast_media
Folder containing the encoded live broadcast video files created by the shell account. These files can be viewed by using QuickTime or VLC Media Player (https://www.videolan.org/vlc/). VLC Media Player is an open-source application that gives you the ability to play media from your computer or a disk, or to stream it from the Web.
----------------------
profile_media
Folder including current profile avatar image and header/banner image from the account profile, if they have been uploaded.
----------------------
spaces-metadata.js
- id: Unique id for the space.
- creatorUserId: The space creator’s Twitter user ID.
- hostUserIds: Twitter user IDs of users that have admin/moderator authorization of this space.
- speakers: Users that have participated in this space. It includes participants’ Twitter user IDs and start/end time of their spoken sessions. If data archive is generated at the time the space is live, it will include only the active speakers at the moment. If space has finished, then it will include everyone that participated.
- createdAt: Space creation time.
- endedAt: Space end time.
- totalParticipating: Total number of users participating in the space when the data archive is generated.
- totalParticipated: Total number of users that have participated in this space.
- invitedUserIds: Twitter user IDs of users that are chosen by the host through space conversation control.
----------------------
spaces_media
Folder containing the spaces audio files created by the account. These files can be viewed by using QuickTime or VLC Media Player (https://www.videolan.org/vlc/). VLC Media Player is an open-source application that gives you the ability to play media from your computer or a disk, or to stream it from the Web.
----------------------
tweets_media
Folder of images, videos, and/or gifs shared in the account’s Tweets. Note: this folder does not include media hosted on other platforms but linked on Twitter (for example, Youtube videos).

If Tweets have been produced and there is associated media, you can match the media to the Tweet data file. The filename for each media file in the tweets_media folder contains a numerical ID that corresponds to a Tweet in the Tweet file. By searching the Tweet file for the numeric portion of the filename of the media, you can find the corresponding Tweet.

If your production includes a Tweet file and did not include a tweets_media folder, this is because there was no media associated with the Tweet file.
----------------------

=== IDENTIFIERS ===
(Real name, alias, postal address, telephone number, unique identifiers (such as a device identifier, cookies, mobile ad identifiers), customer number, Internet Protocol address, email address, account name, and other similar identifiers)

account-creation-ip.js
- accountId: Unique identifier for the account.
- userCreationIp: IP address at account creation.
----------------------
contact.js
- id: Unique identifiers for the contacts imported to the account.
- emails: Emails of the contacts imported to the account.
- phoneNumbers: Phone numbers of the contacts imported to the account.
----------------------
email-address-change.js
- accountId: Unique identifier for the account.
- changedAt: Date and time the email address was changed.
- changedFrom: Email address associated with the account prior to the change.
- changedTo: New email address associated with the account.
----------------------
ip-audit.js
- accountId: Unique identifier for the account.
- createdAt: Date and time of a login to the account.
- loginIp: IP address associated with the login.
- loginPortNumber: Port number associated with the login.
----------------------
periscope-account-information.js
- id: Periscope shell account unique identifier automatically created as soon as the user goes to the "Live" section of the News Camera. A Periscope shell account will be created for the Twitter user before the user goes live.
- displayName: Periscope account name ported over from the Twitter account when the shell account was created.
- username: Periscope account @username ported over from the Twitter account when the shell account was created.
- createdAt: Date and time the "shell account" was created.
- isTwitterUser: Indicates whether the Periscope account is also a Twitter user. This is always true.
- twitterId: Unique identifier for the Twitter account.
- twitterScreenName: The Twitter account’s current @username. Note that the @username may change but the account ID will remain the same for the lifetime of the account.
----------------------
periscope-ban-information.js
- periscopeBanActions: A list of timestamps and reasons an account was disabled.
- periscopeBanOverrideActions: A list of timestamps and ban reasons that an administrator has determined were incorrectly automatically applied to the account.
----------------------
phone-number.js
- phoneNumber: Phone number currently associated with the account if a phone number has been provided.
----------------------
screen-name-change.js
- accountId: Unique identifier for the account.
- changedAt: Date and time the name was changed.
- changedFrom: Previous screen name associated with the account.
- changedTo: New screen name associated with the account.
----------------------
sso.js
- ssoId: Single Sign On ID for account using Google or Apple SSO
- ssoEmail: Email associated to SSO
- associationMethodType: Method the user used to associate to SSO, Signup or Login
- createdAt: Time association to SSO was made
----------------------

=== ONLINE ACTIVITY ===
(Internet and other electronic network activity information, including, but not limited to, information regarding interactions with websites, applications, or advertisements)

account-label.js
- label: The label used to indicate the type of account, if applicable.
- managedByScreenName: Screen name provided as the managing account, if applicable.
----------------------
account-suspension.js
- timeStamp: Date and time of a suspension action.
- action: Action taken regarding account suspension. Accounts are unsuspended by default. This file will be empty unless the account was suspended at some point.
----------------------
account-timezone.js
- accountId: Unique identifier for the account.
- timeZone: Timezone currently associated with the account.
----------------------
account.js
- email: Email address currently associated with the account if an email address has been provided.
- createdVia: Client application used when the account was created. For example: “web” if the  account was created from a browser.
- username: The account’s current @username. Note that the @username may change but the account ID will remain the same for the lifetime of the account.
- accountId: Unique identifier for the account.
- createdAt: Date and time when the account was created.
- accountDisplayName: The account’s name as displayed on the profile.
----------------------
ad-engagements.js
- ad: Promoted Tweets the account has engaged with and any associated metadata.
- deviceInfo: Information about the device where the engagement occurred such as its ID and operating system.
- displayLocation: Location where the ad was engaged with on Twitter.
- promotedTweetInfo: Information about the associated tweet such as unique identifier, text, URLs and media when applicable.
- advertiserInfo: Advertiser name and screen name.
- matchedTargetingCriteria: Targeting criteria that were used to run the campaign.
- impressionTime: Date and time when the ad was viewed.
- engagementAttributes: Type of engagement as well as date and time when it occurred.
----------------------
ad-impressions.js
- ad: Promoted Tweets the account has viewed and any associated metadata.
- deviceInfo: Information about the device where the impression was viewed such as its ID and operating system.
- displayLocation: Location where the ad was viewed on Twitter.
- promotedTweetInfo: Information about the associated tweet such as unique identifier, text, URLs and media when applicable.
- advertiserInfo: Advertiser name and screen name.
- matchedTargetingCriteria: Targeting criteria that were used to run the campaign.
- impressionTime: Date and time when the ad was viewed.
----------------------
ad-mobile-conversions-attributed.js
- ad: Mobile application events associated with the account in the last 90 days which are attributable to a Promoted Tweet engagement on Twitter.
- attributedConversionType: Type of activity specifically associated with the event.
- mobilePlatform: Platform on which the event happened. For example: iOS or Android.
- conversionEvent: Information about the event itself such as installing or signing up.
- applicationName: Name of the application in which the event occurred.
- conversionValue: Value associated with the event.
- conversionTime: Date and time of the event.
- additionalParameters: Other optional parameters associated with the event such as a currency or product category.
----------------------
ad-mobile-conversions-unattributed.js
- ad: Mobile application events associated with the account in the last 10 days which may become attributable to a Promoted Tweet engagement on Twitter in the future.
- mobilePlatform: Platform on which the event happened. For example: iOS or Android.
- conversionEvent: Information about the event itself such as installing or signing up.
- applicationName: Name of the application in which the event occurred.
- conversionValue: Value associated with the event.
- conversionTime: Date and time of the event.
- additionalParameters: Other optional parameters associated with the event such as a currency.
----------------------
ad-online-conversions-attributed.js
- ad: Web events associated with the account in the last 90 days which are attributable to a Promoted Tweet engagement on Twitter.
- attributedConversionType: Type of activity specifically associated with the event.
- eventType: Information about the event itself such as viewing a page.
- conversionPlatform: Platform on which the event happened. For example: desktop.
- advertiserInfo: Advertiser name and screen name.
- conversionValue: Value associated with the event.
- conversionTime: Date and time of the event.
- additionalParameters: Other optional parameters associated with the event such as a currency or product category.
----------------------
ad-online-conversions-unattributed.js
- ad: Web events associated with the account in the last 90 days which may become attributable to a Promoted Tweet engagement on Twitter in the future.
- eventType: Information about the event itself such as viewing a page.
- conversionPlatform: Platform on which the event happened. For example: desktop.
- conversionUrl: URL of the website on which the event occurred.
- advertiserInfo: Advertiser name and screen name.
- conversionValue: Value associated with the event.
- conversionTime: Date and time of the event.
- additionalParameters: Other optional parameters associated with the event such as a currency or product category.
----------------------
ads-revenue-sharing.js
- status: The user's status of the Ads Revenue Sharing program.
- enrolledAt: The ISO8601 timestamp of when the user was enrolled into the Ads Revenue Sharing program.
- paidAt: The ISO8601 timestamp of when the payout was made.
- payoutAmountUsd: The payout amount in USD.
----------------------
app.js
- appId: Identifier of the app Twitter believes may be installed on devices associated with the user.
- appNames: Name of the app Twitter believes may be installed on devices associated with the user.
----------------------
article-metadata.js
- authorId: Twitter ID of the author of this Twitter article.
- createdatMs: Timestamp of the creation of this Twitter article
- updatedAtMs: Timestamp of the last update of this Twitter article
- visibility: Visiblity of the article
- tweetId: TweetId associated with the article
- firstPublishedAtMs: Timestamp of the first time this Twitter article was first published
- lifecycleState: State of the Twitter article: Draft or Published
----------------------
article.js
- id: Unique identifier for the article.
- title: The title of the article as specified by you.
- content: Content of the article split by sections with each has details for the text content, mentions, hashtags and styles applied to the text.
- coverMedia: The cover media of the article.
- media: The medias associated with the article
----------------------
block.js
- accountId: Unique identifiers of accounts currently blocked by the account.
- userLink: Link to information about the blocked users’ profiles if accessible to the account. For example, this information might not be accessible if blocked profiles are protected or deactivated.
----------------------
branch-links.js
- timestamp: Date and time of when the user clicked on the external (off-Twitter) link that prompted them, for example, to download the Twitter app. Data is limited to the last 21 days on iOS and Android devices.
- landingPage: URL indicating where the user landed on Twitter.
- externalReferrerUrl: URL indicating where the user came from before landing on Twitter.
- channel: Tracking parameter always set to Twitter.
- feature: Tracking parameter indicating the Twitter product surface area where the user clicked.
- campaign: Tracking parameter indicating the name of the marketing campaign which the user clicked.
----------------------
catalog-item.js
- catalogProduct: A product linked directly to the catalog
- productKey: Unique identifier for the product
- productId: ID of the product provided by you
- catalogId: Unique identifier for the catalog. It represents the catalog to which the product belongs to.
- lastUpdatedAt: Timestamp when the product was last updated by you
- createdFromDataSource: Source of the data when the product was first created
- updatedFromDataSource: Source of the data when the product was last updated
- title: The title of the product as specified by you
- description: The description of the product as specified by you
- productUrl: externalUrl is the url of the product as specified by you. When the product is clicked, it gets redirected to this link.  tcoUrl is the Twitter shortened url version of the external product url you provided. 

- price: currencyCode is the currency code of the price of the product as specified by you. microValue is the micro value of the price. It is calculated as the actual price specified by you multiplied by 1000000.

- coverMedia: twitterMediaUrl is the internal twitter domain url of the cover media. It is generated by the system when the cover media is uploaded to Twitter. externalUrl is the url to be crawled to extract cover media for the product as specified by you. 

- additionalMedia: List of additional media consisting of external and internal urls. The external url is the one specified by you and the internal url is the system  generated after crawling the external url for extracting media and uploading the media in the twitter media services.

- mobileUrl: externalUrl is the mobile url of the product as specified by you.  tcoUrl is the Twitter shortened url version of the external mobile url.

- salePrice: currencyCode is the currency code of the sale price of the product as specified by you. microValue is the micro value of the sale price. It is calculated as the actual sale price specified by you multiplied by 1000000.

- saleStartTime: Timestamp when the sale starts as specified by you
- saleEndTime: Timestamp when the sale ends as specified by you
- googleProductCategory: The google product category of the product as specified by you
- customProductType: The custom product types of the product as specified by you
- brand: The brand of the product as specified by you.
- catalogProductGroup: A product group linked directly to the catalog
- productGroupKey: Unique identifier for a product group
- productGroupId: ID of the product group as specified by you
- products: List of products belonging to this product group as specified by you
----------------------
commerce-catalog.js
- catalogId: Unique identifier for the catalog
- catalogName: The name of the catalog as specified by you
- catalogType: The type of catalog, always set to Product
- authorUserId: Your twitter user id
- lastUpdatedAt: Timestamp when the catalog was last updated by you
----------------------
community-note-batsignal.js
- signalId: Unique identifier for the Community Note bat signal.
- userId: The Twitter user ID of the author of the Community Note Bat Signal.
- tweetId: Unique identifier for the Tweet annotated.
- createdAt: Day and time at which the Community Note bat signal was created.
- sourceLink: A source link provided with the Community Note Bat Signal.
----------------------
community-note-rating.js
- noteId: Unique identifier for the Community note.
- userId: The Twitter user ID of the author of the Community note rating.
- createdAt: Day and time at which the Community note rating was created.
- agree: Indicates whether the Twitter user agrees or not with the Community note, if available.
- helpful: Indicates whether the Twitter user finds the Community note helpful or not helpful, if available.
- helpfulTags: Tags the user added to this Community note, if available. (Options may include but are not limited to “clear“, “good source”, etc.)
- nothelpfulTags: Tags the user added to this Community note, if available. (Options may include but are not limited to “outdated“, “incorrect“, etc.)
- helpfulnessLevel: Indicates whether the Twitter user finds the Community note helpful or not, if available. (Options may include but are not limited to "helpful", "somewhat helpful", "not helpful", etc.)
- userAlias: The Community alias of the author of the Community note rating.
----------------------
community-note-tombstone.js
- noteId: Unique identifier for the Community note.
- userId: The Twitter user ID of the author of the Community note.
- createdAt: Day and time at which the Community note rating was created.
- deletedAt: Day and time at which the Community note rating was deleted.
----------------------
community-note.js
- noteId: Unique identifier for the Community note.
- userId: The Twitter user ID of the author of the Community note.
- createdAt: Day and time at which the Community note was created.
- tweetId: Unique identifier for the Tweet annotated.
- summary: Text of the Community note; users may explain why they think a Tweet is misleading and include what they believe to be correct information.
- classification: Classification the user added to this Community note, if available. (Options may include but are not limited to "not misleading," "harmfully misleading," "potentially misleading," etc.)
- believable: User-entered multiple choice response to note writing question: “If this tweet were widely spread, its message would likely be believed by:” (Options may include but are not limited to “believable by few”, “believable by many”, etc.) 
- trustworthySources: Binary indicator, based on user-entered multiple choice in response to note writing question “Did you link to sources you believe most people would consider trustworthy?” (Options may include: 1 if “Yes” is selected, 0 if “No” is selected) 
- misleadingTags: User-entered checkbox in response to question “Why do you believe this tweet may be misleading?” (Check all that apply question type)
- notMisleadingTags: User-entered checkbox in response to question “Why do you believe this tweet is not misleading?” (Check all that apply question type).
- harmful: User-entered multiple choice response to note writing question: “If many believed this tweet, it might cause:”. (Options may include but are not limited to “little harm”, “considerable harm”, etc.)
- validation: User-entered multiple choice response to note writing question: “Finding and understanding the correct information would be:” (Options may include but are not limited to “easy”, “challenging”.)
- userAlias: The Community alias of the author of the Community note.
----------------------
community_tweet.js
This JSON file contains all the Tweets posted in Communities and not deleted. The definitions for each of the variables that may be included in any particular Tweet are available in our API documentation: https://developer.twitter.com/en/docs/tweets/post-and-engage/api-reference/post-statuses-update.
----------------------
connected-application.js
- name: Name of the application.
- description: Brief description of the application as provided by the organization.
- approvedAt: Date and time when the account authorized the application.
- permissions: List of permissions granted to the connected application by the Twitter account. For example: read or write.
- id: Unique identifier for the application.
----------------------
deleted-note-tweet.js
- noteTweetId: Note Tweet id associated with a tweet
- createdAt: Date and time a Note Tweet is created at
- lifecycle: Lifecycle state of a note tweet
- updatedAt: Date and time the lifecycle state of Note Tweet is updated at
- core: Core fields for a note tweet such as entity information (hashtag, cashtag, url, mentions), richtext and text
----------------------
deleted-tweet-headers.js
This JSON file contains metadata associated with Tweets that you have deleted, but have not yet been deleted from our production systems.
- tweetId: Unique identifier for the Tweet
- userId: Your Twitter user ID
- createdAt: Tweet creation timestamp
- deletedAt: Tweet deletion timestamp
----------------------
deleted-tweets.js
The "deleted-tweets.txt" file contains Tweets that have been deleted in the last 14 days but have not yet been deleted from our production systems as these systems have a deletion schedule of approximately 14 days. The file may contain deleted edited tweets if applicable. Users can edit a tweet up to five times; as such there are up to 5 edited tweets with unique "editTweetIds," all connected by the "initialTweetID."
----------------------
device-token.js
- token: Token associated with a mobile device or web browser that was used to sign up or log in to this account through twitter.com or one of the other Twitter owned or operated apps within the last 18 months.
- lastSeenAt: Date and time of most recent use. Please note that there may be instances where older tokens do show this information.
- clientApplicationId: Unique identifier of the application associated with the token. Please note that there may be instances where older tokens do not have a unique identifier associated with them.
- clientApplicationName: Name of the application associated with the token. Please note that there may be instances where older tokens do not have an application name associated with them.
- createdAt: Data and time of the creation of the token.
----------------------
direct-message-group-headers.js
- conversationId: Unique identifier for the Direct Message group conversation. Each conversation has a unique randomly generated conversation ID. Within a conversation, the Direct Messages are ordered in reverse chronological order, meaning that the latest Direct Message will be at the top of the list.
- id: Unique identifier for a specific Direct Message within the conversation.
- senderId: Unique identifier for the account who sent the Direct Message.
- createdAt: Date and time the Direct Message was sent.
- joinConversation: Metadata about when the account joined the conversation.
- participantsJoin: Metadata about when another participant joined the conversation. This data is only available if the account was in the conversation when another participant joined.
- participantsLeave: Metadata about when another participant left the conversation. This data is only available if the account was in the conversation when another participant left.
----------------------
direct-message-headers.js
- id: Unique identifier for a specific Direct Message within the conversation.
- senderId: Unique identifier for the account who sent the Direct Message.
- recipientId: Unique identifier for the account who received the Direct Message.
- createdAt: Date and time the Direct Message was sent.
----------------------
direct-message-mute.js
- accountId: Unique identifiers of accounts currently muted by the account.
- userLink: Link to information about the muted users’ profiles if accessible to the account. For example, this information might not be accessible if muted profiles are protected or deactivated.
----------------------
direct-messages-group.js
- conversationId: Unique identifier for the Direct Message group conversation. Each conversation has a unique randomly generated conversation ID. Within a conversation, the Direct Messages are ordered in reverse chronological order, meaning that the latest Direct Message will be at the top of the list.
- text: Text content of the Direct Message.
- mediaUrls: Link included in the Direct Message if applicable.
- senderId: Unique identifier for the account who sent the Direct Message.
- id: Unique identifier for a specific Direct Message within the conversation.
- createdAt: Day and time of when the Direct Message was sent.
- reactionSenderID: Unique identifier for the account that provided the reaction.
- reactionKey: Reaction type (for example, laugh, wow, cry, heart, fire, thumbs up, thumbs down).
- reactionEventID: Unique identifier for the reaction event.
- reactionCreatedAt: Day and time of when the reaction was made.
- joinConversation: Metadata about when the account joined the conversation. This field might not be available due to deletions initiated by the account or other participants.
- participantsJoin: Metadata about when another participant joined the conversation. This field might not be available due to deletions initiated by the account or other participants.
- participantsLeave: Metadata about when another participant left the conversation. This field might not be available due to deletions initiated by the account or other participants.
- conversationNameUpdate: Metadata about when a participant changed the name of the conversation including it name.
----------------------
direct-messages.js
- recipientId: Unique identifier for the account who received the Direct Message.
- text: Text content of the Direct Message.
- reactionSenderID: Unique identifier for the account that provided the reaction.
- reactionKey: Reaction type (for example, laugh, wow, cry, heart, fire, thumbs up, thumbs down).
- reactionEventID: Unique identifier for the reaction event.
- reactionCreatedAt: Day and time of when the reaction was made.
- mediaUrls: Link to media included in the Direct Message if applicable.
- urls: Details about a URL link included in the Direct Message, if applicable.
- senderId: Unique identifier for the account who sent the Direct Message.
- id: Unique identifier for a specific Direct Message within the conversation.
- createdAt: Date and time the Direct Message was sent.
----------------------
expanded-profile.js
This JSON file contains all expanded profile information.

Specifically, an expanded profile is comprised of sections. Each section can have a title and 1 or more blocks.

Blocks can be of different types, such as rich text or work experience. Different block types can have different fields.
----------------------
follower.js
- accountId: Unique identifiers for the other accounts that follow this account.
- userLink: Link to information about the blocked users’ profiles if accessible to the account. For example, this information might not be accessible if blocked profiles are protected or deactivated.
----------------------
following.js
- accountId: Unique identifiers for the other accounts this account follows.
- userLink: Link to information about the blocked users’ profiles if accessible to the account. For example, this information might not be accessible if blocked profiles are protected or deactivated.
----------------------
grok-chat-item.js
- accountId: Unique identifier of the account who sent a message to Grok.
- createdAt: Date and time the Grok chat message was sent.
- chatId: Unique identifier of the chat the account had with Grok.
- message: Text content of the Grok Message
- sender: Type of the sender in the Grok conversation.
- postIds: Unique identifiers of the Posts in the Grok response.
- grokMode: Grok mode during the conversation.
- attachments: Files uploaded by user or generated by Grok in the conversation
----------------------
grok_chat_media
Folder of images and/or pdfs shared in the account’s Grok conversations. Note: this folder does not include media hosted on other platforms but linked on Twitter (for example, Instagram photos).

If Grok Messages have been produced and there is associated media, you can match the media to the Grok conversation data file. The filename for each media file in the grok_chat_media folder contains a numerical ID that corresponds to a message in the grok_chat_item file. By searching the grok_chat_item file for the numeric portion of the filename of the media, you can find the corresponding Grok message.

If your production includes a grok_chat_item file and did not include a grok_chat_media folder, this is because there was no media associated with the grok_chat_item file.
----------------------
key-registry.js
- userId: Unique identifier for the user account
- deviceId: Unique identifier for the device registered/deregistered for Encrypt Dms
- registrationToken: Registration token with one to one mapping with deviceId
- identityKey: Public key used to set up encrypted dm session
- userAgent: String content extracted from request header that includes device metadata info
- createdAt: Date and time of registration/unregistration
----------------------
like.js
- tweetId: Unique identifiers for the Tweets liked.
- expandedUrl: Link to the actual tweet on twitter.com if the account has access to it.
- fullText: Text as visible in the tweet if the account has access to it.
----------------------
lists-created.js
- urls: URLs of Lists created by the account.
----------------------
lists-member.js
- urls: URLs of Lists the account has been added to and is eligible to access.
----------------------
lists-subscribed.js
- urls: URLs of Lists the account has subscribed to.
----------------------
moment.js
- momentId: Unique identifier for the Moment.
- createdAt: Date and time the Moment was created.
- createdBy: Unique identifier for the Moment generated by the account.
- title: Title attributed to the Moment.
- tweets: Tweets included in the Moment, including Tweets by other accounts.
- description: Description text on the cover page of the Moment.
----------------------
mute.js
- accountId: Unique identifiers for currently muted accounts.
- userLink: Link to information about the blocked users’ profiles if accessible to the account. For example, this information might not be accessible if blocked profiles are protected or deactivated.
----------------------
ni-devices.js
- deviceType: Manufacturer for devices that are marked as “pushDevice”. For devices marked as “messagingDevice”, the field will indicate “Auth” if the device is only used for two-factor authentication purposes, and “Full” if the device is set to receive notifications from Twitter.
- carrier: Optional field indicating the carrier associated with the device.
- phone_number: Phone number associated with the device.
- deviceVersion: Operating system version associated with the device.
- createdDate: Field indicating when the association between the device and the Twitter account was made.
- updatedDate: Field indicating the last time this association was updated.
- udid: Field indicating the application-generated device ID. This ID is unique to the device and persists through device updates, but not through device reinstallations.
----------------------
note-tweet.js
- noteTweetId: Note Tweet id associated with a tweet
- createdAt: Date and time a Note Tweet is created at
- lifecycle: Lifecycle state of a note tweet
- updatedAt: Date and time the lifecycle state of Note Tweet is updated at
- core: Core fields for a note tweet such as entity information (hashtag, cashtag, url, mentions), richtext and text
----------------------
periscope-broadcast-metadata.js
- id: Unique id for the broadcast posted by the shell account.
- hasLocation: Flag to indicate if the broadcast has associated location.
- latitude: Specific latitude for the broadcast’s location.
- longitude: Specific longitude for the broadcast’s location.
- city: (optional) City where the broadcast took place.
- country: (optional) Country where the broadcast took place.
- createdAt: Time broadcast was created.
- updatedAt: Time broadcast was updated or modified.
----------------------
periscope-comments-made-by-user.js
- broadcastId: Unique id for the broadcast posted by the shell account.
- byAccountId: Account ID of the commenter.
- createdAt: Time comment was made.
- text: The comment text.
----------------------
periscope-followers.js
Other accounts that follow this shell account.
----------------------
periscope-profile-description.js
- description: Periscope account description ported over from the Twitter account when the shell account was created.
- profileImageUrls: URLs of the profile images used with the Twitter account when the shell account was created.
----------------------
product-drop.js
- id: Unique identifier for a product drop
- userId: Your twitter user id
- productSetId: ID of the product set containing the product being dropped as specified by you
- hashtag: Hashtag attached to the drop provided by you
- dropTime: Timestamp when the product is going to be dropped as provided by you
----------------------
product-set.js
- productSetId: Unique identifier for the product set
- catalogId: Unique identifier for the catalog. It represents the catalog to which the product set belongs to
- productSetType: Represents the type of the product set. It is generated during creation of product set in Shopping Manager
- name: Name of the product set provided by you
- description: Description of the product set provided by you
- lastUpdatedAt: Timestamp when the product set was last updated by you
- items: List of items that belong to this product set as provided by you. The product set item can be either a product or a product group.  itemType represents the Type of the item. The possible values are Product, ProductGroup.  itemKey represents the Key of the item. If the itemType is product, then itemKey represents productKey. If the itemType is productGroup, then itemKey represents the productGroupKey.
----------------------
professional_data.js
- accountId: Unique identifier for the account.
- professionalId: Unique identifier for the Professional account.
- professionalType: Business or Creator, depending on which type of Professional account the user selected.
- categoryName: The category of Professional account, as selected by the user.
- setToDisplay: Whether the category is displayed to profile visitors, as selected by the user.
- createdAt: Date and time the Professional account was created.
- creationSource: What path (eg. feature) the creation happened from
- moduleId: Unique identifier for the module
- website: URL chosen by the user to display in the location spotlight
- addresssLine1: First line of the address used for the location spotlight
- city: City selected for the location spotlight
- administrativeArea: State-like selected for the location spotlight
- postalCode: Postal code selected for the location spotlight
- country: Country selected for the location spotlight
- phone: Phone selected for the location spotlight with country code and number
- countryCode: Country code selected as phone number on the location spotlight
- number: Phone number on the location spotlight without country code
- email: Email selected for the location spotlight (not the same one as the account's email)

- timezone: Timezone selected for the location spotlight
- openTimes: Open hours for the location on the location spotlight
- openTimesType: Type of open hours selected. Values are "Always Open", "Regular Hours", None
- regular: When type is "Regular Hours", daily definitions go here
- weekday: Day of the week for which the open hours apply
- slots: Slots for ranges of open hours for the given weekday
- hourOpen: Hour that the venue opens
- minuteOpen: Minute that the venue opens
- hourClose: Hour that the venue closes
- minuteClose: minute that the venue closes
- appleAppStore: URL for an Apple App Store app added to the Mobile App Spotlight
- googlePlayStore: URL for a Google Play Store app added to the Mobile App Spotlight
- rawUrl: URL chosen by the user to display in the link spotlight
- ctaDisplay: Call to action string chosen by the user to display in the link spotlight
----------------------
profile.js
- bio: Current account bio as displayed on the profile, if the user has provided one.
- website: Current account website as displayed on the profile, if the user has provided one.
- location: Current account location as displayed on the profile, if the user has provided one.
- avatarMediaUrl: Link to the current profile avatar image, if the user has provided one.
- headerMediaUrl: Link to the current profile header image, if the user has provided one.
----------------------
protected-history.js
- protectedAt: Date and time the "Protect your Tweets" setting was used in the last six months.
- action: Whether the account is protected or unprotected.
----------------------
reply-prompt.js
This file will be empty unless the account was prompted to review their reply containing potentially harmful or offensive language.
- promptId: The unique identifier for the prompt received.
- userId: The Twitter user ID that was prompted.
- proposedTweetText: The text of the reply that has been prompted. This text is retained for 30 days, even if the proposed Tweet is deleted or revised.
- inReplyToTweetId: The unique identifier for the Tweet the prompted reply was directed to.
- createdAt: The date and time when the user was prompted on a reply that was identified as containing potentially harmful or offensive language.
- promptActionType: Indicates the action taken by the account when prompted, for example editing or deleting the tweets. Each number represents an action according to the following legend: Send Tweet = 1, Edit Tweet = 2, Close App = 4, Prompt Not Shown = 5 (ie: the account was already prompted earlier), Delete Tweet = 10, Back Button = 11 (Android Only).
----------------------
saved-search.js
- savedSearchId: Unique identifier for a saved search.
- query: Actual search query entered by the account.
----------------------
shop-module.js
- moduleId: Unique identifier of the shop spotlight module. 
- userId: Your twitter user id
- isEnabled: Represents if the module is enabled by you. 
- productSetIds: list of product set ids provided by you. Items from this set will be displayed in the shop module
- displayType: Represents the display type of the shop module. Possible values: Carousel, Button
----------------------
shopify-account.js
- shopDomain: Unique identifier for a Shopify account
- termsOfServiceAccepted: Represents whether the shopify app terms of of service is accepted by you
- appOnboardingComplete: Represents whether all the onboarding steps are completed by you
- userId: Your twitter user id
- catalogId: ID of the catalog to which the shopify account is linked
- shopCurrency: The shopify account currency when the account is first synced with Twitter
- createdAt: Timestamp when the account was first linked to Twitter
- updatedAt: Timestamp when the account was last updated with Twitter
----------------------
smartblock.js
Accounts smartblocked by Twitter on the User's behalf, when the User had Safety mode turned on. Includes metadata.
- accountId: Unique identifiers of accounts currently blocked by the account.
- userLink: Link to information about the blocked users' profiles. The information from the link might not be accessible if the account is protected or has been deactivated.

- createdAt: Timestamp that the Smartblock was created.
- expiresAt: Timestamp that the Smartblock expires.
- ttl: smartblock duration in string format (1 day, 7 days, etc.)
----------------------
tweet-headers.js
This JSON file contains metadata associated with Tweets which have not been deleted.
- tweetId: Unique identifier for the Tweet
- userId: Your Twitter user ID
- createdAt: Tweet creation timestamp
----------------------
tweetdeck.js
- title: The title of the deck
- columns: The columns in the deck
- pathname: The type of each column. For some column types, it contains extra attributes, such as query in /search?q=london, or list-id in /list/27456987
----------------------
tweets.js
This JSON file contains available Tweets which have not been deleted and it includes edited tweets if applicable. Users can edit a tweet up to five times; as such there are up to 5 edited tweets with unique “editTweetIds,” all connected by the “initialTweetID.” The definitions for each of the variables that may be included in any particular Tweet are available in our API documentation: https://developer.twitter.com/en/docs/tweets/post-and-engage/api-reference/post-statuses-update.
----------------------
twitter-shop.js
- shopId: Unique identifier for a Shop
- userId: Your twitter user id
- isEnabled: Represents if the shop is enabled by you
- name: Name of the shop provided by you
- description: Description of the shop provided by you
- productSetIds: list of product set ids provided by you. Items from this set will be displayed in the shop
----------------------
user-link-clicks.js
- tweetId: Unique identifier for the Tweet the user clicked on when using Twitter on iOS or Android.
- finalUrl: URL indicating where the Tweet linked to off Twitter.
- timeStampOfInteraction: Date and time of when the click occured. This file includes 30 days of data from the time the archive was generated.
----------------------
verified-organization.js
- affiliatedToAccounts: List of verfied organization accounts that the current account is affiliated to
- affiliates: List of affiliates are connected to the current verfied ogranization account
- screenName: The affiliate or affiliation account’s current @username.
- verfiedType: The flag to indicate account verified type.
- createdAt: The ISO8601 date and time of the verified organization created or affiliate created in verified organization.
----------------------
verified.js
- accountId: Unique identifier for the account.
- verified: Indicates whether the account is verified.
----------------------

=== INFERENCES ===
(Inferences drawn to create a profile about the user reflecting their preferences, characteristics, predispositions, behavior, and attitudes)

personalization.js
- languages: Languages associated with the account. Please note that this information may be inferred.
- genderInfo: Gender associated with the account. Please note that this information may be inferred.
- interests: Interests associated with the account. Please note that this information may be inferred.
- partnerInterests: Interests from partners that are associated with the account.
- numAudiences: Number of tailored audiences (audiences generated by advertisers) the account is a part of.
- advertisers: List of screennames for the advertisers that own the tailored audiences the account is a part of.
- lookalikeAdvertisers: List of screen names for the advertisers that own the look-alike audiences the account is a part of.
- inferredAgeInfo: Date of birth Twitter has inferred about the account and corresponding current age.
- locationHistory: Location history associated with the account based on activity from the last 60 days.
- shows: TV shows associated with the account. Please note that this information may be inferred.
- doNotReachAdvertisers: List of screen names for the advertisers that own Do Not Reach Lists the account is a part of
----------------------

=== PROTECTED CLASSIFICATIONS ===
(Characteristics of certain legally protected classifications.)

For information about the language(s), gender, and age associated with the account (which may be inferred), please refer to personalization.js.

ageinfo.js
- ageInfo: Date of birth provided to Twitter and corresponding current age.
----------------------

=== LOCATION DATA ===

For location data associated with the account, please refer to location in profile.js and locationHistory in personalization.js. For information about a Periscope broadcast location, please refer to periscope-broadcast-metadata.js.
----------------------


INFORMATION REGARDING DATA COLLECTION, PROCESSING, AND DISCLOSURE
===================
For information about the sources from which we collect personal information, our purposes for collection, and how we may share it, please read the Twitter Privacy Policy (www.twitter.com/privacy) and https://help.twitter.com/rules-and-policies/data-processing-legal-bases.
