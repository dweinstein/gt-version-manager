Class {
	#name : 'GtVmInstallation',
	#superclass : 'Object',
	#instVars : [
		'path',
		'version'
	],
	#category : 'GToolkit-VersionManager',
	#package : 'GToolkit-VersionManager'
}

{ #category : 'views' }
GtVmInstallation >> gtActionLaunchFor: anAction [
	<gtAction>
	^ anAction button
		tooltip: 'Launch this GT version';
		priority: 1;
		icon: BrGlamorousVectorIcons play;
		action: [ self launch ]
]

{ #category : 'views' }
GtVmInstallation >> gtDetailsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Details';
		priority: 1;
		items: [ {
			'Version' -> self version.
			'Path' -> self path fullName.
			'Exists' -> self path exists.
		} , (self path exists 
			ifTrue: [ { 'Size on disk' -> self humanReadableSizeOnDisk } ]
			ifFalse: [ #() ]) ];
		column: 'Property' text: #key;
		column: 'Value' text: #value
]

{ #category : 'views' }
GtVmInstallation >> gtFilesFor: aView [
	<gtView>
	self path exists ifFalse: [ ^ aView empty ].
	^ aView forward
		title: 'Files';
		priority: 10;
		object: [ self path ];
		view: #gtTreeFor:
]

{ #category : 'accessing' }
GtVmInstallation >> humanReadableSizeOnDisk [
	| s |
	s := self sizeOnDisk.
	s < (1024 * 1024) ifTrue: [ ^ (s / 1024) rounded asString, ' KB' ].
	s < (1024 * 1024 * 1024) ifTrue: [ ^ (s / (1024 * 1024)) rounded asString, ' MB' ].
	^ ((s / (1024 * 1024 * 1024)) roundTo: 0.1) asString, ' GB'
]

{ #category : 'actions' }
GtVmInstallation >> launch [
	"Launch this GT installation (macOS only for now)"
	| app |
	app := self path allDirectories 
		detect: [ :d | d basename endsWith: '.app' ] 
		ifNone: [ self error: 'No .app bundle found' ].
	LibC system: ('open "', app fullName, '"')
]

{ #category : 'accessing' }
GtVmInstallation >> path [
	^ path
]

{ #category : 'accessing' }
GtVmInstallation >> path: aFileReference [
	path := aFileReference
]

{ #category : 'printing' }
GtVmInstallation >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: ' (';
		nextPutAll: self version;
		nextPut: $)
]

{ #category : 'accessing' }
GtVmInstallation >> sizeOnDisk [
	"Total size of the installation directory in bytes"
	| total |
	total := 0.
	self path allFiles do: [ :f | total := total + f size ].
	^ total
]

{ #category : 'accessing' }
GtVmInstallation >> version [
	^ version
]

{ #category : 'accessing' }
GtVmInstallation >> version: aString [
	version := aString
]
