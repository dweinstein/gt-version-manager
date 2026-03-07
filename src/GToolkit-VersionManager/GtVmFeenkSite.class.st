Class {
	#name : 'GtVmFeenkSite',
	#superclass : 'Object',
	#instVars : [
		'entries'
	],
	#category : 'GToolkit-VersionManager',
	#package : 'GToolkit-VersionManager'
}

{ #category : 'accessing' }
GtVmFeenkSite >> baseUrl [
	^ 'https://dl.feenk.com/gt/'
]

{ #category : 'accessing' }
GtVmFeenkSite >> buildsForVersion: aVersionString [
	^ self versionedBuilds select: [ :e | e versionString = aVersionString ]
]

{ #category : 'accessing' }
GtVmFeenkSite >> entries [
	^ entries ifNil: [ entries := self fetchEntries ]
]

{ #category : 'private' }
GtVmFeenkSite >> fetchEntries [
	"Fetch and parse the nginx directory listing from dl.feenk.com/gt/"
	| html lines result |
	html := ZnClient new
		url: self baseUrl;
		get.
	lines := html lines.
	result := OrderedCollection new.
	lines do: [ :line |
		| regex |
		regex := '<a href="([^"]+)">.*</a>\s+(\S+ \S+)\s+(\S+)' asRegex.
		(regex search: line) ifTrue: [
			| name dateStr sizeStr |
			name := regex subexpression: 2.
			dateStr := regex subexpression: 3.
			sizeStr := regex subexpression: 4.
			(name = '../') ifFalse: [
				result add: (GtVmFeenkEntry new
					fileName: name;
					dateString: dateStr;
					fileSize: ([ sizeStr asInteger ] on: Error do: [ :e | 0 ])) ] ] ].
	^ result
]

{ #category : 'views' }
GtVmFeenkSite >> gtAllFilesFor: aView [
	<gtView>
	^ aView columnedList
		title: 'All files';
		priority: 10;
		items: [ self entries ];
		column: 'File' text: #fileName;
		column: 'Size' text: #humanReadableSize width: 100;
		column: 'Date' text: #dateString width: 150
]

{ #category : 'views' }
GtVmFeenkSite >> gtBuildsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Builds';
		priority: 5;
		items: [ self versionedBuilds ];
		column: 'Version' text: #versionString width: 100;
		column: 'Platform' text: #platform width: 80;
		column: 'Arch' text: #architecture width: 80;
		column: 'Size' text: #humanReadableSize width: 80;
		column: 'Date' text: #dateString width: 150
]

{ #category : 'views' }
GtVmFeenkSite >> gtVersionsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Versions';
		priority: 1;
		items: [ self versions collect: [ :v | v -> (self buildsForVersion: v) ] ];
		column: 'Version' text: [ :assoc | 
			| text |
			text := assoc key asRopedText.
			(assoc key = GtImage instance version versionString)
				ifTrue: [ text bold ].
			text ] width: 120;
		column: 'Platforms' text: [ :assoc | assoc value size ] width: 80;
		column: 'Date' text: [ :assoc | assoc value first dateString ] width: 150;
		send: [ :assoc | assoc value ]
]

{ #category : 'accessing' }
GtVmFeenkSite >> latestVersion [
	^ self versions first
]

{ #category : 'printing' }
GtVmFeenkSite >> printOn: aStream [
	super printOn: aStream.
	entries ifNotNil: [
		aStream
			nextPutAll: ' [';
			print: self versions size;
			nextPutAll: ' versions, ';
			print: self versionedBuilds size;
			nextPutAll: ' builds]' ]
]

{ #category : 'actions' }
GtVmFeenkSite >> refresh [
	entries := nil
]

{ #category : 'accessing' }
GtVmFeenkSite >> releasePointers [
	"Small text files pointing to the latest versioned zip"
	^ self entries select: [ :e | e isReleasePointer ]
]

{ #category : 'accessing' }
GtVmFeenkSite >> versionedBuilds [
	"Only versioned platform-specific builds"
	^ self entries select: [ :e | e isVersionedBuild ]
]

{ #category : 'accessing' }
GtVmFeenkSite >> versions [
	"Unique version strings available on dl.feenk.com, sorted descending"
	| versionStrings |
	versionStrings := (self versionedBuilds collect: [ :e | e versionString ]) asSet asOrderedCollection.
	^ versionStrings sorted: [ :a :b | 
		(GtRlSemanticVersionNumber createFromString: a) >= (GtRlSemanticVersionNumber createFromString: b) ]
]
