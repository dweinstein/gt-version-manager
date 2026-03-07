Class {
	#name : 'GtVmAsset',
	#superclass : 'GtVmObject',
	#category : 'GToolkit-VersionManager',
	#package : 'GToolkit-VersionManager'
}

{ #category : 'accessing' }
GtVmAsset >> architecture [
	"Extract arch from asset name, e.g. 'aarch64' from 'GlamorousToolkit-MacOS-aarch64-v1.1.247.zip'"
	| parts |
	parts := $- split: self name.
	parts size >= 4 ifFalse: [ ^ 'unknown' ].
	^ parts third
]

{ #category : 'accessing' }
GtVmAsset >> contentType [
	^ rawData at: 'content_type'
]

{ #category : 'accessing' }
GtVmAsset >> createdAt [
	^ (rawData at: 'created_at') asDateAndTime
]

{ #category : 'accessing' }
GtVmAsset >> digest [
	"SHA-256 digest from GitHub, format: 'sha256:hexstring'"
	^ rawData at: 'digest' ifAbsent: [ nil ]
]

{ #category : 'accessing' }
GtVmAsset >> downloadCount [
	^ rawData at: 'download_count'
]

{ #category : 'accessing' }
GtVmAsset >> downloadUrl [
	^ rawData at: 'browser_download_url'
]

{ #category : 'views' }
GtVmAsset >> gtDetailsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Details';
		priority: 1;
		items: [ {
			'Name' -> self name.
			'Platform' -> self platform.
			'Architecture' -> self architecture.
			'Size' -> self humanReadableSize.
			'Downloads' -> self downloadCount.
			'Content type' -> self contentType.
			'Created' -> self createdAt.
			'Digest' -> (self digest ifNil: [ 'N/A' ]).
			'Download URL' -> self downloadUrl.
			'Current platform?' -> self isForCurrentPlatform.
		} ];
		column: 'Property' text: #key;
		column: 'Value' text: #value
]

{ #category : 'accessing' }
GtVmAsset >> humanReadableSize [
	"Return size in human-readable format"
	| s |
	s := self size.
	s < 1024 ifTrue: [ ^ s asString, ' B' ].
	s < (1024 * 1024) ifTrue: [ ^ (s / 1024) rounded asString, ' KB' ].
	^ (s / (1024 * 1024)) rounded asString, ' MB'
]

{ #category : 'testing' }
GtVmAsset >> isForCurrentPlatform [
	"True if this asset matches the current OS and architecture"
	| os arch machineArch |
	self isPlatformBuild ifFalse: [ ^ false ].
	os := Smalltalk os isWindows
		ifTrue: [ 'Windows' ]
		ifFalse: [ Smalltalk os isMacOS
			ifTrue: [ 'MacOS' ]
			ifFalse: [ 'Linux' ] ].
	machineArch := (LibC resultOfCommand: 'uname -m') trimBoth.
	arch := (machineArch = 'arm64' or: [ machineArch = 'aarch64' ])
		ifTrue: [ 'aarch64' ]
		ifFalse: [ 'x86_64' ].
	^ self platform = os and: [ self architecture = arch ]
]

{ #category : 'testing' }
GtVmAsset >> isPlatformBuild [
	"True if this is a platform-specific build (not image-only, sha256, or gemstone)"
	^ (self name endsWith: '.zip') 
		and: [ (self name includesSubstring: 'sha256') not
		and: [ (self name includesSubstring: 'image-without-world') not
		and: [ (self name includesSubstring: 'gt4gemstone') not ] ] ]
]

{ #category : 'accessing' }
GtVmAsset >> name [
	^ rawData at: 'name'
]

{ #category : 'accessing' }
GtVmAsset >> platform [
	"Extract OS from asset name, e.g. 'MacOS' from 'GlamorousToolkit-MacOS-aarch64-v1.1.247.zip'"
	| parts |
	parts := $- split: self name.
	parts size >= 3 ifFalse: [ ^ 'unknown' ].
	^ parts second
]

{ #category : 'printing' }
GtVmAsset >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: ' (';
		nextPutAll: self name;
		nextPut: $)
]

{ #category : 'accessing' }
GtVmAsset >> size [
	^ rawData at: 'size'
]
