Class {
	#name : 'GtVmAssetGroup',
	#superclass : 'GtVmObject',
	#category : 'GToolkit-VersionManager',
	#package : 'GToolkit-VersionManager'
}

{ #category : 'enumerating' }
GtVmAssetGroup >> collect: aBlock [
	^ self items collect: aBlock
]

{ #category : 'enumerating' }
GtVmAssetGroup >> do: aBlock [
	^ self items do: aBlock
]

{ #category : 'accessing' }
GtVmAssetGroup >> forCurrentPlatform [
	"Asset matching the current OS and architecture"
	^ self items detect: [ :each | each isForCurrentPlatform ] ifNone: [ nil ]
]

{ #category : 'views' }
GtVmAssetGroup >> gtItemsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Assets';
		priority: 1;
		items: [ self platformBuilds ];
		column: 'Platform' text: #platform width: 100;
		column: 'Architecture' text: #architecture width: 100;
		column: 'Size' text: #humanReadableSize width: 80;
		column: 'Downloads' text: #downloadCount width: 80;
		column: 'Name' text: #name
]

{ #category : 'accessing' }
GtVmAssetGroup >> items [
	^ rawData collect: [ :each | GtVmAsset new rawData: each ]
]

{ #category : 'accessing' }
GtVmAssetGroup >> platformBuilds [
	"Only zip assets that are platform-specific builds (not sha256 files, not image-only, not gemstone)"
	^ self items select: [ :each | each isPlatformBuild ]
]

{ #category : 'printing' }
GtVmAssetGroup >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: ' [';
		print: self size;
		nextPutAll: ' assets]'
]

{ #category : 'enumerating' }
GtVmAssetGroup >> select: aBlock [
	^ self items select: aBlock
]

{ #category : 'enumerating' }
GtVmAssetGroup >> size [
	^ self items size
]
