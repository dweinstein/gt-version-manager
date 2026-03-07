Class {
	#name : 'GtVmReleaseGroup',
	#superclass : 'GtVmObject',
	#category : 'GToolkit-VersionManager',
	#package : 'GToolkit-VersionManager'
}

{ #category : 'enumerating' }
GtVmReleaseGroup >> collect: aBlock [
	^ self items collect: aBlock
]

{ #category : 'enumerating' }
GtVmReleaseGroup >> do: aBlock [
	^ self items do: aBlock
]

{ #category : 'views' }
GtVmReleaseGroup >> gtDownloadStatsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Download stats';
		priority: 10;
		items: [ self items ];
		column: 'Version' text: #tagName width: 120;
		column: 'Total' text: #totalDownloads width: 80;
		column: 'Per platform' text: [ :r | 
			| builds |
			builds := r assets platformBuilds.
			', ' join: (builds collect: [ :a | a platform, ':', a downloadCount asString ]) ]
]

{ #category : 'views' }
GtVmReleaseGroup >> gtItemsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Releases';
		priority: 1;
		items: [ self items ];
		column: 'Version' text: [ :r | 
			r isCurrentVersion 
				ifTrue: [ r tagName asRopedText bold ]
				ifFalse: [ r tagName ] ] width: 120;
		column: 'Published' text: [ :r | r publishedAt asLocalStringYMDHM ] width: 150;
		column: 'Author' text: #authorLogin width: 120;
		column: 'Downloads' text: #totalDownloads width: 80;
		column: 'Platforms' text: [ :r | r assets platformBuilds size ] width: 70
]

{ #category : 'accessing' }
GtVmReleaseGroup >> items [
	^ rawData collect: [ :each | GtVmRelease new rawData: each ]
]

{ #category : 'accessing' }
GtVmReleaseGroup >> latest [
	^ self items first
]

{ #category : 'printing' }
GtVmReleaseGroup >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: ' [';
		print: self size;
		nextPutAll: ' releases]'
]

{ #category : 'enumerating' }
GtVmReleaseGroup >> select: aBlock [
	^ self items select: aBlock
]

{ #category : 'enumerating' }
GtVmReleaseGroup >> size [
	^ self items size
]
