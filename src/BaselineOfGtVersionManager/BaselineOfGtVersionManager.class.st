Class {
	#name : 'BaselineOfGtVersionManager',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfGtVersionManager',
	#package : 'BaselineOfGtVersionManager'
}

{ #category : 'baseline' }
BaselineOfGtVersionManager >> baseline: spec [
	<baseline>
		^ spec for: #common do: [
			spec package: 'GToolkit-VersionManager'
		]
]
