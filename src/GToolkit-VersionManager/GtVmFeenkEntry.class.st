Class {
	#name : 'GtVmFeenkEntry',
	#superclass : 'Object',
	#instVars : [
		'fileName',
		'fileSize',
		'dateString'
	],
	#category : 'GToolkit-VersionManager',
	#package : 'GToolkit-VersionManager'
}

{ #category : 'accessing' }
GtVmFeenkEntry >> architecture [
	"Extract architecture from filename"
	(self fileName includesSubstring: 'aarch64') ifTrue: [ ^ 'aarch64' ].
	(self fileName includesSubstring: 'x86_64') ifTrue: [ ^ 'x86_64' ].
	(self fileName includesSubstring: 'Arm64') ifTrue: [ ^ 'aarch64' ].
	(self fileName includesSubstring: '64') ifTrue: [ ^ 'x86_64' ].
	^ 'unknown'
]

{ #category : 'accessing' }
GtVmFeenkEntry >> dateString [
	^ dateString
]

{ #category : 'accessing' }
GtVmFeenkEntry >> dateString: aString [
	dateString := aString
]

{ #category : 'accessing' }
GtVmFeenkEntry >> downloadUrl [
	^ 'https://dl.feenk.com/gt/', self fileName
]

{ #category : 'accessing' }
GtVmFeenkEntry >> fileName [
	^ fileName
]

{ #category : 'accessing' }
GtVmFeenkEntry >> fileName: aString [
	fileName := aString
]

{ #category : 'accessing' }
GtVmFeenkEntry >> fileSize [
	^ fileSize
]

{ #category : 'accessing' }
GtVmFeenkEntry >> fileSize: anInteger [
	fileSize := anInteger
]

{ #category : 'views' }
GtVmFeenkEntry >> gtDetailsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Details';
		priority: 1;
		items: [ {
			'File name' -> self fileName.
			'Version' -> (self versionString ifNil: [ 'N/A' ]).
			'Platform' -> self platform.
			'Architecture' -> self architecture.
			'Size' -> self humanReadableSize.
			'Date' -> self dateString.
			'Download URL' -> self downloadUrl.
			'Versioned build?' -> self isVersionedBuild.
			'Release pointer?' -> self isReleasePointer.
		} ];
		column: 'Property' text: #key;
		column: 'Value' text: #value
]

{ #category : 'accessing' }
GtVmFeenkEntry >> humanReadableSize [
	| s |
	s := self fileSize.
	s < 1024 ifTrue: [ ^ s asString, ' B' ].
	s < (1024 * 1024) ifTrue: [ ^ (s / 1024) rounded asString, ' KB' ].
	^ (s / (1024 * 1024)) rounded asString, ' MB'
]

{ #category : 'testing' }
GtVmFeenkEntry >> isReleasePointer [
	"True if this is a release pointer file (small text file pointing to latest)"
	^ (self fileName includesSubstring: '-release')
		and: [ (self fileName endsWith: '.zip') not ]
]

{ #category : 'testing' }
GtVmFeenkEntry >> isVersionedBuild [
	"True if this is a versioned platform-specific build"
	^ self versionString isNotNil
		and: [ (self fileName endsWith: '.zip')
		and: [ (self fileName includesSubstring: 'sha256') not ] ]
]

{ #category : 'accessing' }
GtVmFeenkEntry >> platform [
	"Extract OS from filename"
	(self fileName includesSubstring: 'Linux') ifTrue: [ ^ 'Linux' ].
	(self fileName includesSubstring: 'MacOS') ifTrue: [ ^ 'MacOS' ].
	(self fileName includesSubstring: 'Windows') ifTrue: [ ^ 'Windows' ].
	^ 'unknown'
]

{ #category : 'printing' }
GtVmFeenkEntry >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: ' (';
		nextPutAll: self fileName;
		nextPut: $)
]

{ #category : 'accessing' }
GtVmFeenkEntry >> versionString [
	"Extract version from filename, e.g. 'v1.1.247' from 'GlamorousToolkit-MacOS-aarch64-v1.1.247.zip'"
	| match |
	match := 'v[0-9]+\.[0-9]+\.[0-9]+' asRegex.
	(match search: self fileName)
		ifTrue: [ ^ match subexpression: 1 ]
		ifFalse: [ ^ nil ]
]
