//
//  ContentView.swift
//  wordScramble
//
//  Created by mithun srinivasan on 27/05/23.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var newWord = ""
    @State private var rootWord = ""
    
    @State private var errorMessage = ""
    @State private var errorTitle = ""
    @State private var showingError = false
    
    @State private var score = 0
    
    var body: some View {
        NavigationView{
            List{
                Section{
                    TextField("write a word using \(rootWord)", text: $newWord)
                        .autocapitalization(.none)
                }
                Section{
                    HStack{
                        Button(action: { startGame()
                        }) {Text("New game")}
                        Spacer()
                        Text("your score is: \(score)")
                    }
                }
                Section{
                    ForEach(usedWords, id: \.self) { word in
                        HStack{
                            Text(word)
                            Spacer()
                            Image(systemName: "\(word.count).circle")
                        }
                    }
                }
                
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            
        }
    }
    
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 2 else {
            wordError(title: "less than 3 letter", message: "try words with more than two letters")
            newWord = " "
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            newWord = " "
            return
        }

        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            newWord = " "
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            newWord = " "
            return
        }
        
        usedWords.insert(answer, at: 0)
        score += answer.count
        newWord = " "
    }
    func startGame(){
        
        if let startWordURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWord = try? String(contentsOf: startWordURL){
                let allwords = startWord.components(separatedBy: "\n")
                rootWord = allwords.randomElement() ?? "silkworm"
                usedWords = []
                score = 0
                return
            }
        }
        fatalError("could not load start.txt from bundle")
    }
    
    func isOriginal(word: String)-> Bool{
        !usedWords.contains(word)
    }
    
    func isPossible (word: String)->Bool{
        var clone = rootWord
        for letter in word {
            if let position = clone.firstIndex(of: letter){
                clone.remove(at: position)
            }
            else {return false}
        }
        return true
    
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
