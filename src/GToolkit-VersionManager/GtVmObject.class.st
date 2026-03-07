Class {
	#name : 'GtVmObject',
	#superclass : 'Object',
	#instVars : [
		'rawData'
	],
	#category : 'GToolkit-VersionManager',
	#package : 'GToolkit-VersionManager'
}

{ #category : 'views' }
GtVmObject >> gtRawDataFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Raw data';
		priority: 50;
		items: [ self rawData isDictionary
			ifTrue: [ self rawData associations sorted: [ :a :b | a key < b key ] ]
			ifFalse: [ self rawData ] ];
		column: 'Property' text: #key;
		column: 'Value' text: #value
]

{ #category : 'accessing' }
GtVmObject >> rawData [
	^ rawData ifNil: [ Dictionary new ]
]

{ #category : 'accessing' }
GtVmObject >> rawData: aDictionary [
	rawData := aDictionary
]
