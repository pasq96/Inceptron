//
//  ViewController.swift
//  Test
//
//  Created by Pasquale Coppola on 09/03/18.
//  Copyright © 2018 Pasquale Coppola. All rights reserved.
//

import UIKit

class ManualResistorViewController: UIViewController, UIPickerViewDelegate,  UIPickerViewDataSource {
	
	

//	@IBOutlet weak var myLabel: UILabel!
	@IBOutlet weak var picker1: UIPickerView!
	@IBOutlet weak var picker2: UIPickerView!
	@IBOutlet weak var picker3: UIPickerView!
	@IBOutlet weak var picker4: UIPickerView!
	@IBOutlet weak var myButton: UIButton!
	@IBOutlet weak var labelValue: UILabel!
	@IBOutlet weak var titleResistanceLabel: UILabel!
	
	struct NamedColor
	{
		var name: String
		var color: UIColor
		init(name : String, color : UIColor)
		{
			self.name = name;
			self.color = color
		}
	}
	
	var pickerData: [NamedColor] = []
	var pickerDataMultiplier: [NamedColor] = []
	var pickerDataTolerance: [NamedColor] = []
	
	var selectedPicker1, selectedPicker2, selectedPicker3, selectedPicker4: String!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.picker1.delegate = self
		self.picker1.dataSource = self
		self.picker2.delegate = self
		self.picker2.dataSource = self
		self.picker3.delegate = self
		self.picker3.dataSource = self
		self.picker4.delegate = self
		self.picker4.dataSource = self
		
		//customize button
		myButton.layer.cornerRadius = 10
		myButton.titleEdgeInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
		picker1.tintColor=UIColor.clear
		//set color selected to default - black 
		selectedPicker1 = "Black"
		selectedPicker2 = "Black"
		selectedPicker3 = "Black"
		selectedPicker4 = "Brown"
		//--
		
		let brown = #colorLiteral(red: 0.5616386027, green: 0.4023959335, blue: 0.2233105485, alpha: 1)
		let black = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
		let orange = #colorLiteral(red: 1, green: 0.4984615517, blue: 0.08212189493, alpha: 1)
		let yellow = #colorLiteral(red: 1, green: 0.953677904, blue: 0.01457490452, alpha: 1)
		let green = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
		let blue = #colorLiteral(red: 0, green: 0.3738567995, blue: 1, alpha: 1)
		let violet = #colorLiteral(red: 0.5465450394, green: 0, blue: 1, alpha: 1)
		let grey = #colorLiteral(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
		let white = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
		let gold = #colorLiteral(red: 0.8549019608, green: 0.6549019608, blue: 0.1254901961, alpha: 1)
		let silver = #colorLiteral(red: 0.7977497578, green: 0.7977686524, blue: 0.7977585196, alpha: 1)
		let red = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
	
		pickerData = [
			NamedColor(name: "Black", color: black),
			NamedColor(name: "Brown", color: brown),
			NamedColor(name: "Red", color: red),
			NamedColor(name: "Orange", color: orange),
			NamedColor(name: "Yellow", color: yellow),
			NamedColor(name: "Green", color: green),
			NamedColor(name: "Blue", color: blue),
			NamedColor(name: "Violet", color: violet),
			NamedColor(name: "Grey", color: grey),
			NamedColor(name: "White", color: white)]
		
		pickerDataMultiplier = [
			NamedColor(name: "Black", color: black),
			NamedColor(name: "Brown", color: brown),
			NamedColor(name: "Red", color: red),
			NamedColor(name: "Orange", color: orange),
			NamedColor(name: "Yellow", color: yellow),
			NamedColor(name: "Green", color: green),
			NamedColor(name: "Blue", color: blue),
			NamedColor(name: "Violet", color: violet),
			NamedColor(name: "Gold", color: gold),
			NamedColor(name: "Silver", color: silver)]
		
		pickerDataTolerance = [
			NamedColor(name: "Brown", color: brown),
			NamedColor(name: "Red", color: red),
			NamedColor(name: "Green", color: green),
			NamedColor(name: "Blue", color: blue),
			NamedColor(name: "Violet", color: violet),
			NamedColor(name: "Grey", color: grey),
			NamedColor(name: "Gold", color: gold),
			NamedColor(name: "Silver", color: silver)]
//		picker1.dataSource = pickerData as? UIPickerViewDataSource
//		// Do any additional setup after loading the view, typically from a nib.
		
		
	}
	
	
	@IBAction func onClick(_ btn: UIButton, forEvent event: UIEvent)
	{
		let band1 = valueBandFromColor(color: selectedPicker1)
		let band2 = valueBandFromColor(color: selectedPicker2)
		let band3 = valueMultiplierFromColor(color: selectedPicker3)
		let band4 = valueToleranceFromColor(color: selectedPicker4)
		
		
		let n = Double ("\(band1)\(band2)")!
//		print (n)
		let finalVal = n*band3
//		print (finalVal)
		
		//enable labels
		labelValue.isHidden = false
		titleResistanceLabel.isHidden = false
		
		//copy result into labels
		
		if (finalVal < 1000)
		{
			labelValue.text = String (format: "%g", finalVal) + " Ω \(band4)"
		}
			else
			if (finalVal >= 1000) && (finalVal < 1000000)
			{
				labelValue.text = String (format: "%g", finalVal/1000) + " KΩ \(band4)"
			}
				else
				if (finalVal >= 1000000)
				{
					labelValue.text = String (format: "%g", finalVal/1000000) + " MΩ \(band4)"
				}
		
		
		
		
		
	}
	
	func valueBandFromColor (color: String) -> Int //1,2 BAND
	{
		var value: Int = 0
		switch color {
		case "Black": value = 0
		case "Brown": value = 1
		case "Red": value = 2
		case "Orange": value = 3
		case "Yellow": value = 4
		case "Green": value = 5
		case "Blue": value = 6
		case "Violet": value = 7
		case "Grey": value = 8
		case "White": value = 9
		default:
			break
		}
		return value
	}
	
	func valueMultiplierFromColor (color: String) -> Double //band MULTIPLIER
	{
		var value: Double = 0
		switch color {
		case "Black": value = 1
		case "Brown": value = 10
		case "Red": value = 100
		case "Orange": value = 1000
		case "Yellow": value = 10000
		case "Green": value = 100000
		case "Blue": value = 1000000
		case "Violet": value = 10000000
		case "Gold": value = 0.1
		case "Silver": value = 0.01
		default:
			break
		}
		return value
	}
	
	func valueToleranceFromColor (color: String) -> String //band TOLERANCE
	{
		var value: String = ""
		switch color {
		case "Brown": value = "± 1%"
		case "Red": value = "± 2%"
		case "Green": value = "± 0.5%"
		case "Blue": value = "± 0.25%"
		case "Violet": value = "± 0.10%"
		case "Grey": value = "± 0.05%"
		case "Gold": value = "± 5%"
		case "Silver": value = "± 10%"
		default:
			break
		}
		return value
	}
	

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


	//PICKER VIEWS
	
	
	
	//MARK: - Delegates and data sources
	//MARK: Data Sources
	func numberOfComponents (in pickerView: UIPickerView) -> Int {
		return 1
	}
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		if (pickerView.accessibilityIdentifier! == "Picker3")
		{
			return pickerDataMultiplier.count
		}
		if (pickerView.accessibilityIdentifier! == "Picker4")
		{
			return pickerDataTolerance.count
		}
		return pickerData.count
	}
	//MARK: Delegates
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		if (pickerView.accessibilityIdentifier! == "Picker3")
		{
			return pickerDataMultiplier[row].name
		}
		if (pickerView.accessibilityIdentifier! == "Picker4")
		{
			return pickerDataTolerance[row].name
		}
		return pickerData[row].name
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		switch(pickerView.accessibilityIdentifier!)
		{
			
		case "Picker1":
			selectedPicker1 = pickerData[row].name
//			print(selectedPicker1)
			case "Picker2": selectedPicker2 = pickerData[row].name
//			print(selectedPicker2)
			case "Picker3": selectedPicker3 = pickerDataMultiplier[row].name
//			print(selectedPicker3)
			case "Picker4": selectedPicker4 = pickerDataTolerance[row].name
//			print(selectedPicker4)
		default:
//			print("error")
			break
		}
	}
	
	func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
		let titleData = pickerData[row].name
		let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedStringKey.font:UIFont(name: "Georgia", size: 26.0)!,NSAttributedStringKey.foregroundColor:UIColor.blue])
		return myTitle
	}
	/* less conservative memory version
	func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
	let pickerLabel = UILabel()
	let titleData = pickerData[row]
	let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 26.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
	pickerLabel.attributedText = myTitle
	//color  and center the label's background
	let hue = CGFloat(row)/CGFloat(pickerData.count)
	pickerLabel.backgroundColor = UIColor(hue: hue, saturation: 1.0, brightness:1.0, alpha: 1.0)
	pickerLabel.textAlignment = .Center
	return pickerLabel
	}
	*/
	
	/* better memory management version */
	func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
		var pickerLabel = view as! UILabel!
		var color: UIColor
		if view == nil {  //if no label there yet
			pickerLabel = UILabel()
			//color the label's background
			if (pickerView.accessibilityIdentifier! == "Picker3")
			{
				color = pickerDataMultiplier[row].color
			}
			else if (pickerView.accessibilityIdentifier! == "Picker4")
			{
				color = pickerDataTolerance[row].color
			}
			else {color = pickerData[row].color}
			pickerLabel?.backgroundColor = color
		}
		return pickerLabel!
		
	}
	
	func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
		return 36.0
	}
	// for best use with multitasking , dont use a constant here.
	//this is for demonstration purposes only.
	func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
		return 200
	}
	
	//---PICKER VIEWS
	
}


