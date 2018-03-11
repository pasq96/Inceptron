//
//  InfoViewController.swift
//  Resistor
//
//  Created by Pasquale Coppola on 11/03/18.
//  Copyright © 2018 Team 5.2. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
	
	

	@IBOutlet weak var myPicker: UIPickerView!
	var pickerData:[String] = []
	override func viewDidLoad() {
        super.viewDidLoad()

		pickerData = ["Pasquale Coppola", "Giuseppe Valitutto", "Domenico Caliendo", "Giovanni Allegretti", "Francesco D'Auria"]
		// Connect data:
		self.myPicker.delegate = self
		self.myPicker.dataSource = self
        // Do any additional setup after loading the view.
    }

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	// The number of columns of data
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	// The number of rows of data
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return pickerData.count
	}
	
	// The data to return for the row and component (column) that's being passed in
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return pickerData[row]
	}
    
	// Catpure the picker view selection
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		// This method is triggered whenever the user makes a change to the picker selection.
		// The parameter named row and component represents what was selected.
	}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
