//
//  ViewController.swift
//  Bow Ties
//
//  Created by Pietro Rea on 7/12/15.
//  Copyright © 2015 Razeware. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
  
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var ratingLabel: UILabel!
  @IBOutlet weak var timesWornLabel: UILabel!
  @IBOutlet weak var lastWornLabel: UILabel!
  @IBOutlet weak var favoriteLabel: UILabel!
    
  var managedContext: NSManagedObjectContext!
  var currentBowtie: Bowtie!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //You call insertSampleData(), which you implemented earlier. Since viewDidLoad() can be called every time the app is launched, insertSampleData() itself performs a fetch to make sure it isn’t inserting the sample data into Core Data multiple times.
    
    insertSampleData()
    
    //You create a fetch request for the purpose of fetching the newly inserted Bowtie entities. The segmented control has tabs to filter by color, so the predicate adds the condition to find the bow ties that match the selected color. Predicates are both very flexible and very powerful—you’ll read more about them in chapter 4.
    //For now, you should know that this particular predicate is looking for bow ties that have their searchKey property set to the segmented control’s first button title, “R” in this case.
    
    let request = NSFetchRequest(entityName:"Bowtie")
    let firstTitle = segmentedControl.titleForSegmentAtIndex(0)
    request.predicate = NSPredicate(format:"searchKey == %@", firstTitle!)
    
        do {
            let results =
            try managedContext.executeFetchRequest(request) as! [Bowtie]
            currentBowtie = results.first
            populate(currentBowtie)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    
    }//end of viewDidLoad()
  
  
  @IBAction func segmentedControl(control: UISegmentedControl) {
        let selectedValue = control.titleForSegmentAtIndex(control.selectedSegmentIndex)
        
        let request = NSFetchRequest(entityName:"Bowtie")
        
        request.predicate = NSPredicate(format:"searchKey == %@", selectedValue!)
        
        do {
        let results =
        try managedContext.executeFetchRequest(request) as! [Bowtie]
        currentBowtie = results.first
            populate(currentBowtie)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
  }//end segmentedControl
  
  @IBAction func wear(sender: AnyObject) {
            
            //This method takes the currently selected bow tie and increments its timesWorn attribute by one. Since the timesWorn property is an NSNumber, you have to first unbox the integer, increment it and wrap it up nicely into another NSNumber.
            
            let times = currentBowtie.timesWorn!.integerValue
            currentBowtie.timesWorn = NSNumber(integer: (times + 1))
            
            //Then, you change the lastWorn date to today and save the managed context to commit these changes to disk. Finally, you populate the user interface to visualize these changes.
            currentBowtie.lastWorn = NSDate()
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
            }
            populate(currentBowtie)
  }//end wear
  
  @IBAction func rate(sender: AnyObject) {
    
        //Tapping on Rate now brings up an alert view with a single text field, a cancel button and a save button. 
        //Tapping the save button calls the method updateRating
    
        let alert = UIAlertController(title: "New Rating", message: "Rate this bow tie",
        preferredStyle: UIAlertControllerStyle.Alert)
    
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default,
        handler: { (action: UIAlertAction!) in
        })
    
        let saveAction = UIAlertAction(title: "Save", style: .Default,
        handler: { (action: UIAlertAction!) in
    
            let textField = alert.textFields![0] as UITextField
            self.updateRating(textField.text!)
        })
    
        alert.addTextFieldWithConfigurationHandler {
                (textField: UITextField!) in textField.keyboardType = .NumberPad
            }
    
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
    
        presentViewController(alert, animated: true, completion: nil)
  }//end rate

    func insertSampleData() {
        //The first method, insertSampleData, checks for any bow ties and if none are present, it grabs the bow tie information in SampleData.plist, iterates through each bow tie dictionary and inserts a new Bowtie entity into your Core Data store. At the end of this iteration, it saves the managed context property to commit these changes to disk.
        
        let fetchRequest = NSFetchRequest(entityName: "Bowtie")
        
        fetchRequest.predicate = NSPredicate(format: "searchKey != nil")
        
        let count = managedContext.countForFetchRequest(fetchRequest, error: nil)
        
        if count > 0 {return }
        
        let path = NSBundle.mainBundle().pathForResource("SampleData", ofType: "plist")
        
        let dataArray = NSArray(contentsOfFile: path!)!
        
        for dict : AnyObject in dataArray {
            
            let entity = NSEntityDescription.entityForName("Bowtie", inManagedObjectContext: managedContext)
        
            let bowtie = Bowtie(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
            let btDict = dict as! NSDictionary
        
            bowtie.name = btDict["name"] as? String
            bowtie.searchKey = btDict["searchKey"] as? String
            bowtie.rating = btDict["rating"] as? NSNumber
        
            let tintColorDict = btDict["tintColor"] as? NSDictionary
            bowtie.tintColor = colorFromDict(tintColorDict!)
        
            let imageName = btDict["imageName"] as? String
            let image = UIImage(named:imageName!)
            let photoData = UIImagePNGRepresentation(image!)
            bowtie.photoData = photoData
        
            bowtie.lastWorn = btDict["lastWorn"] as? NSDate
            bowtie.timesWorn = btDict["timesWorn"] as? NSNumber
            bowtie.isFavorite = btDict["isFavorite"] as? NSNumber
        }
    }//end insertSampleData
    
    func colorFromDict(dict: NSDictionary) -> UIColor {
            //SampleData.plist stores colors in a dictionary that contains three keys: red, green and blue. This method takes in this dictionary and returns 
                //a bonafide UIColor.
                
            let red = dict["red"] as! NSNumber
            let green = dict["green"] as! NSNumber
            let blue = dict["blue"] as! NSNumber
            let color = UIColor(red: CGFloat(red)/255.0,green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: 1)
        
            return color
    }//end colorFromDict

    
    func populate(bowtie: Bowtie) {
            imageView.image = UIImage(data:bowtie.photoData!)
            nameLabel.text = bowtie.name
            ratingLabel.text = "Rating: \(bowtie.rating!.doubleValue)/5"
                
            timesWornLabel.text = "# times worn: \(bowtie.timesWorn!.integerValue)"
                
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .ShortStyle
            dateFormatter.timeStyle = .NoStyle
                
            lastWornLabel.text = "Last worn: " + dateFormatter.stringFromDate(bowtie.lastWorn!)
                
            favoriteLabel.hidden = !bowtie.isFavorite!.boolValue
                
            view.tintColor = bowtie.tintColor as! UIColor
    }//end populate
    
    func updateRating(numericString: String) {
            
            //You convert the text from the alert view’s text field into a double and use it to update the current bow ties rating property.
            //Finally, you commit your changes as usual by saving the managed context and refresh the UI to see your changes in real time.
            
            currentBowtie.rating = (numericString as NSString).doubleValue
            
            do {
                try managedContext.save()
                populate(currentBowtie)
            } catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
            
                //Handles error of rating a bowtie outside 0-5
                if error.domain == NSCocoaErrorDomain &&
                (error.code == NSValidationNumberTooLargeError || error.code == NSValidationNumberTooSmallError) {
                    rate(currentBowtie)
                }//end error handle
            }//end catch
    }//end updateRating

}// end class viewController