//
//  ContentView.swift
//  BetterRest
//
//  Created by Shaun Heffernan on 1/15/24.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State  private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var alertMessage = "Adjust your settings"
        
    
        
    
    static var defaultWakeTime: Date{
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    var body: some View {
        NavigationStack{
            Form {
                Section{
                    VStack(alignment: .leading, spacing: 0){
                        Text("When do you want to wake up?")
                            .font(.headline)
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .onChange(of: wakeUp) { _ in
                                calculateBedTime()
                            }
                    }
                }
                
                VStack(alignment: .leading, spacing: 0){
                    Text("Desired amount of sleep")
                        .font(.headline)
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                        .onChange(of: sleepAmount) { _ in
                            calculateBedTime()}
                }
                VStack(alignment: .leading, spacing: 0){
                    Text("Daily coffee intake")
                        .font(.headline)
                    Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in:1...20)
                        .onChange(of: coffeeAmount) { _ in
                            calculateBedTime()}
                }
               
                Section("suggested sleep time"){
                    Text(alertMessage)
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity,alignment: .center)

                }
            }
            .navigationTitle("Better Rest")
        }
    }
    
    func calculateBedTime(){
        do{
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour,.minute], from: wakeUp)
            let hour = (components.hour  ?? 0) * 60 * 60
            let minute = (components.hour  ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertMessage = sleepTime.formatted(date: .omitted, time:.shortened)
            
        } catch{
            alertMessage = "Sorry, there was a problem calculating your bedtime"
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
