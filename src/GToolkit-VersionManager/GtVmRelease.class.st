Class {
	#name : 'GtVmRelease',
	#superclass : 'GtVmObject',
	#category : 'GToolkit-VersionManager',
	#package : 'GToolkit-VersionManager'
}

{ #category : 'accessing' }
GtVmRelease >> assetForCurrentPlatform [
	^ self assets forCurrentPlatform
]

{ #category : 'accessing' }
GtVmRelease >> assets [
	^ GtVmAssetGroup new rawData: (rawData at: 'assets')
]

{ #category : 'accessing' }
GtVmRelease >> authorLogin [
	^ (rawData at: 'author') at: 'login'
]

{ #category : 'accessing' }
GtVmRelease >> body [
	"Release notes / changelog text (often nil for GT releases)"
	^ rawData at: 'body' ifAbsent: [ nil ]
]

{ #category : 'accessing' }
GtVmRelease >> createdAt [
	^ (rawData at: 'created_at') asDateAndTime
]

{ #category : 'views' }
GtVmRelease >> gtActionBrowseOnGitHubFor: anAction [
	<gtAction>
	^ anAction button
		tooltip: 'Open on GitHub';
		priority: 10;
		icon: BrGlamorousVectorIcons web;
		action: [ WebBrowser openOn: self htmlUrl ]
]

{ #category : 'views' }
GtVmRelease >> gtAssetsFor: aView [
	<gtView>
	^ aView forward
		title: 'Assets';
		priority: 10;
		object: [ self assets ];
		view: #gtItemsFor:
]

{ #category : 'views' }
GtVmRelease >> gtDetailsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Details';
		priority: 1;
		items: [ {
			'Tag' -> self tagName.
			'Version' -> self version.
			'Published' -> self publishedAt.
			'Author' -> self authorLogin.
			'Total downloads' -> self totalDownloads.
			'Prerelease' -> self isPrerelease.
			'Current version' -> self isCurrentVersion.
			'GitHub URL' -> self htmlUrl.
		} ];
		column: 'Property' text: #key;
		column: 'Value' text: #value
]

{ #category : 'printing' }
GtVmRelease >> gtDisplayOn: aStream [
	aStream nextPutAll: self tagName.
	self isCurrentVersion ifTrue: [
		aStream nextPutAll: ' (current)' ]
]

{ #category : 'accessing' }
GtVmRelease >> htmlUrl [
	^ rawData at: 'html_url'
]

{ #category : 'accessing' }
GtVmRelease >> id [
	^ rawData at: 'id'
]

{ #category : 'testing' }
GtVmRelease >> isCurrentVersion [
	"True if this release matches the running GT image version"
	^ [ self tagName = GtImage instance version versionString ]
		on: Error do: [ :e | false ]
]

{ #category : 'testing' }
GtVmRelease >> isDraft [
	^ rawData at: 'draft' ifAbsent: [ false ]
]

{ #category : 'testing' }
GtVmRelease >> isPrerelease [
	^ rawData at: 'prerelease' ifAbsent: [ false ]
]

{ #category : 'accessing' }
GtVmRelease >> name [
	^ rawData at: 'name'
]

{ #category : 'printing' }
GtVmRelease >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: ' (';
		nextPutAll: self tagName;
		nextPut: $)
]

{ #category : 'accessing' }
GtVmRelease >> publishedAt [
	^ (rawData at: 'published_at') asDateAndTime
]

{ #category : 'accessing' }
GtVmRelease >> tagName [
	^ rawData at: 'tag_name'
]

{ #category : 'accessing' }
GtVmRelease >> targetCommitish [
	^ rawData at: 'target_commitish'
]

{ #category : 'accessing' }
GtVmRelease >> totalDownloads [
	"Sum of download counts across all platform build assets"
	^ self assets platformBuilds
		inject: 0
		into: [ :sum :asset | sum + asset downloadCount ]
]

{ #category : 'accessing' }
GtVmRelease >> version [
	"Parse semantic version from tag name, e.g. 'v1.1.247' -> GtRlSemanticVersionNumber"
	^ GtRlSemanticVersionNumber createFromString: self tagName
]
