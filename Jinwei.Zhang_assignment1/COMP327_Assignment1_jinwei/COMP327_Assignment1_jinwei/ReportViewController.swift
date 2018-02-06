//
//  ReportViewController.swift
//  COMP327_Assignment1_jinwei
//
//  Created by Jinwei Zhang on 28/10/2017.
//  Copyright © 2017 zjw. All rights reserved.
//

import UIKit
import CoreData
import SwiftChart

//this class will generate the report saying how many people have the same option
//with the user who is just save his data 
class ReportViewController: UIViewController {
    
    fileprivate var chart: Chart? // arc
    //this function pop all view controllers
    @IBAction func popAllViewController(_ sender: Any) {
        self.parent?.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func rightButtonAction(sender: UIBarButtonItem){
        //navigate to the the viewController
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier:"homePage")
        
        // this method contain the activity of stack
        let navController = UINavigationController(rootViewController: nextViewController!)
        // Creating a navigation controller with VC1 at the root of the navigation stack.
        self.present(navController, animated:true, completion: nil)
    }
    
    //this method will be called when the view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)
        
        let quantityVeryLow = MyQuantity(number: 0, text: "0")
        let quantityLow = MyQuantity(number: 1, text: "0-5")
        let quantityAverage = MyQuantity(number: 2, text: "5-10")
        let quantityHigh = MyQuantity(number: 3, text: "10-15")
        let quantityVeryHigh = MyQuantity(number: 4, text: "15+")
        let quantity1, quantity2, quantity3, quantity4, quantity5: MyQuantity
        
        var item0,item1,item2,item3:MyItem
        var counterSingle = 0, counterMulti = 0, counterNumeric = 0, counterText = 0
        //fetch the data from core data and put into the graph
        
        if(searchResultResponses?.count == 0){
            //no data in the core data do not have to display
        }else{
            //loop through the response in the core data
            for index in 0...(searchResultResponses?.count)! - 1 {
                //find the same result in this questinnaire
                if(searchResultResponses![index] as Responses).questionnaireID ==
                    questionnarieResult?.questionnaireID {
                    
                    //the questionname for response is type
                    //find the same choice in the core data
                    if searchResultResponses![index].questionName == "single-option" {
                        //check if the label are the same
                        if searchResultResponses![index].label == String(choosenSingle) {
                            counterSingle += 1
                        }
                        //find the same muti result in the core data
                    }else if searchResultResponses![index].questionName == "multi-option" {
                        var choiceString = ""
                        for choice in choosenMuti {
                            choiceString = choiceString + String(choice)
                        }
                        if searchResultResponses![index].label == choiceString {
                            counterMulti += 1
                        }
                        
                        //find the same result in core data for the numeric
                    }else if searchResultResponses![index].questionName == "numeric" {
                        if searchResultResponses![index].label == String(chooseNumber){
                            counterNumeric += 1
                        }
                        
                        //find the same text in the core data
                    }else if searchResultResponses![index].questionName == "text" {
                        if searchResultResponses![index].label == inputComment {
                            counterText += 1
                        }
                        
                    }else {
                        print("failed in count the number of responses")
                    }
                }
            }
        }
        
        //depend on the number of same option in core data, assign the bar chart
        item0 = MyItem(name: "single-option",
                       quantity: generateStatistics(number:counterSingle))
        item1 = MyItem(name: "multi-option",
                       quantity: generateStatistics(number:counterMulti))
        item2 = MyItem(name: "numeric",
                       quantity: generateStatistics(number:counterNumeric))
        item3 = MyItem(name: "text",
                       quantity: generateStatistics(number:counterText))
        
        //below are part of the frame work
        let chartPoints: [ChartPoint] =
            [item0, item1, item2, item3].enumerated().map {index, item in
            let xLabelSettings =
                ChartLabelSettings(font: ExamplesDefaults.labelFont,
                                   rotation: 45,
                                   rotationKeep: .top)
            let x = ChartAxisValueString(item.name, order: index,
                                         labelSettings: xLabelSettings)
            let y = ChartAxisValueString(item.quantity.text,
                                         order: item.quantity.number,
                                         labelSettings: labelSettings)
            return ChartPoint(x: x, y: y)
        }
        
        let xValues =
            [ChartAxisValueString("", order: -1)] +
                chartPoints.map{$0.x} +
                [ChartAxisValueString("", order: 5)]
        
        func toYValue(_ quantity: MyQuantity) -> ChartAxisValue {
            return ChartAxisValueString(quantity.text,
                                        order: quantity.number,
                                        labelSettings: labelSettings)
        }
        
        let yValues = [toYValue(quantityVeryLow),
                       toYValue(quantityLow),
                       toYValue(quantityAverage),
                       toYValue(quantityHigh),
                       toYValue(quantityVeryHigh)]
        
        let xModel = ChartAxisModel(axisValues: xValues,
                                    axisTitleLabel: ChartAxisLabel(text: "questions",
                                                                   settings: labelSettings))
        let yModel =
            ChartAxisModel(axisValues: yValues,
                                    axisTitleLabel: ChartAxisLabel(text: "peopele have same choice with you",
                                                                   settings: labelSettings.defaultVertical()))
        let chartFrame = ExamplesDefaults.chartFrame(view.bounds)
        
        let chartSettings = ExamplesDefaults.chartSettingsWithPanZoom
        
        let coordsSpace =
            ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings,
                                                 chartFrame: chartFrame,
                                                 xModel: xModel,
                                                 yModel: yModel)
        let (xAxisLayer, yAxisLayer, innerFrame)
            = (coordsSpace.xAxisLayer,
               coordsSpace.yAxisLayer,
               coordsSpace.chartInnerFrame)
        
        let minBarSpacing: CGFloat = ExamplesDefaults.minBarSpacing + 16
        
        let generator =
        {(chartPointModel: ChartPointLayerModel,
            layer: ChartPointsLayer,
            chart: Chart) -> UIView? in
            let bottomLeft = layer.modelLocToScreenLoc(x: -1, y: 0)
            
            let barWidth = layer.minXScreenSpace - minBarSpacing
            
            let barViewSettings = ChartBarViewSettings(animDuration: 0.5)
            let (p1, p2): (CGPoint, CGPoint) =
                (CGPoint(x: chartPointModel.screenLoc.x,
                         y: bottomLeft.y),
                 CGPoint(x: chartPointModel.screenLoc.x,
                         y: chartPointModel.screenLoc.y))
            return ChartPointViewBar(p1: p1, p2: p2,
                                     width: barWidth,
                                     bgColor: UIColor.blue.withAlphaComponent(0.6),
                                     settings: barViewSettings)
        }
        
        let chartPointsLayer = ChartPointsViewsLayer(
            xAxis: xAxisLayer.axis,
            yAxis: yAxisLayer.axis,
            chartPoints: chartPoints,
            viewGenerator: generator)
        
        let settings = ChartGuideLinesDottedLayerSettings(
            linesColor: UIColor.black, linesWidth: ExamplesDefaults.guidelinesWidth)
        let guidelinesLayer = ChartGuideLinesDottedLayer(
            xAxisLayer: xAxisLayer,
            yAxisLayer: yAxisLayer,
            settings: settings)
        
        let dividersSettings =  ChartDividersLayerSettings(
            linesColor: UIColor.black,
            linesWidth: Env.iPad ? 1 : 0.2, start: Env.iPad ? 7 : 3, end: 0)
        let dividersLayer = ChartDividersLayer(
            xAxisLayer: xAxisLayer,
            yAxisLayer: yAxisLayer,
            settings: dividersSettings)
        
        let chart = Chart(
            frame: chartFrame,
            innerFrame: innerFrame,
            settings: chartSettings,
            layers: [
                xAxisLayer,
                yAxisLayer,
                guidelinesLayer,
                dividersLayer,
                chartPointsLayer
            ]
        )
        
        view.addSubview(chart.view)
        self.chart = chart
        
        let rightButtonItem = UIBarButtonItem.init(
            title: "Home",
            style: .done,
            target: self,
            action: #selector(rightButtonAction(sender:))
        )
        self.navigationItem.rightBarButtonItem = rightButtonItem
    }
    
    //generate the coorespond quantity for the question result
    fileprivate func generateStatistics(number:Int)->MyQuantity{
        let quantityVeryLow = MyQuantity(number: 0, text: "0")
        let quantityLow = MyQuantity(number: 1, text: "0-5")
        let quantityAverage = MyQuantity(number: 2, text: "5-10")
        let quantityHigh = MyQuantity(number: 3, text: "10-15")
        let quantityVeryHigh = MyQuantity(number: 4, text: "15+")
        if number <= 0 {
            return quantityVeryLow
        }else if number > 0 && number <= 5 {
            return quantityLow
        }else if number > 5 && number <= 10 {
            return quantityAverage
        }else if number > 10 && number <= 15{
            return quantityHigh
        }else{
            return quantityVeryHigh
        }
    }
}


private struct MyQuantity {
    let number: Int
    let text: String
    
    init(number: Int, text: String) {
        self.number = number
        self.text = text
    }
}

private struct MyItem {
    let name: String
    let quantity: MyQuantity
    
    init(name: String, quantity: MyQuantity) {
        self.name = name
        self.quantity = quantity
    }
    
}
