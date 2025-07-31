//
//  ContentView.swift
//  BetterRest
//
//  Created by Sougato Roy on 31/07/25.
//

import SwiftUI
import CoreML

struct ContentView: View {
    // Computed property for default
    static var defaultWakeTime : Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        
        return Calendar.current.date(from: components) ?? .now
    }
    
    // Computed property to show ideal bed time
    var idealBedtime : String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            // more code here
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            //code uses 0 if either the hour or minute can’t be read, but realistically that’s never going to happen so it will result in hour and minute being set to those values in seconds.
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            
            return sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            // something went wrong!
            return "Sorry, there was a problem calculating your bedtime."
        }
    }
    
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    
    var body: some View {
        NavigationStack{
            Form{
                Section{
                    Text("When do you want to wake up?")
                        .font(.headline)
                    //Smaller than .largeTitle
                    
                    DatePicker("Pick a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                Section{
                    Text("How much sleep do you want?")
                        .font(.headline)
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                Section{
                    Text("How much coffee do you drink?")
                        .font(.headline)
                    Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in: 1...20)
//                    Picker("Pick", selection: $coffeeAmount){
//                        ForEach(1..<21){
//                            Text("^[\($0) cup](inflect: true)")
//                        }
//                    }
                    // Swift can handle the pluralization for us! a specialized form of Markdown, which is a common text-format. This syntax tells SwiftUI that the word "cup" needs to be inflected to match whatever is in the coffeeAmount variable
                }
                
                // NEW SECTION: Recommended Bedtime
                Section("Your ideal bedtime is…") {
                    Text(idealBedtime)
                    .font(.largeTitle.weight(.semibold))
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical)
                }
            }
            .navigationTitle("BetterREST")
//            .toolbar{
//                Button("Calculate", action: calculateBedTime)
//            }
        }
//        .alert(alertTitle, isPresented: $showingAlert) {
//            Button("OK") { }
//        } message: {
//            Text(alertMessage)
//        }
        //.padding()
    }
    func calculateBedTime(){
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            // more code here
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            //code uses 0 if either the hour or minute can’t be read, but realistically that’s never going to happen so it will result in hour and minute being set to those values in seconds.
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your ideal bedtime is…"
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            // something went wrong!
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        showingAlert = true
    }
}

#Preview {
    ContentView()
}
