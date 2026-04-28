//
//  WordBank.swift
//  SongLingo
//
//  Created by Jaci on 3/26/26.
//

import SwiftUI

struct WordBank: View {
    //Dummy info (again)
    @State private var wordDemo = WordData(word: "Testing Longer Words", translation: "Cinnamon", wordProficiency: "Learning", totalListeningTime: 12, totalPractices: 5)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                HStack (spacing: 5) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.yellow.opacity(0.5))
                        
                        HStack {
                            Text("New (INT)")
                                .lineLimit(1)
                                .foregroundColor(.black)
                                .font(.system(size: 8.5))
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.purple.opacity(0.4))
                        
                        HStack {
                            Text("Learning (INT)")
                                .lineLimit(1)
                                .foregroundColor(.black)
                                .font(.system(size: 8.5))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.blue.opacity(0.4))
                        
                        HStack {
                            Text("Familiar (INT)")
                                .lineLimit(1)
                                .foregroundColor(.black)
                                .font(.system(size: 8.5))
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.green.opacity(0.6))
                        
                        HStack {
                            Text("Mastered (INT)")
                                .lineLimit(1)
                                .foregroundColor(.black)
                                .font(.system(size: 8.5))
                        }
                        .padding(.vertical, 10)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                }
                .padding(.horizontal)
                
                Divider()
                    .overlay(Color.black)
                
                HStack {
                    VStack (alignment: .leading) {
                        Text(wordDemo.word)
                            //.bold()
                            .font(.title2)
                            .foregroundColor(.black)
                        
                        Text("(\(wordDemo.translation))")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                    }
                    .padding(.horizontal, 10)
                    
                    VStack (alignment: .trailing) {
                        HStack {
                            ZStack {
                                
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.purple.opacity(0.4))
                                    .frame(height: 25)
                                    .frame(width: 100)

                                Text(wordDemo.wordProficiency)
                                    .lineLimit(1)
                                    .foregroundColor(.black)
                                    .font(.system(size: 12))
                            }
                        }
                        
                        HStack {
                            Text("\(wordDemo.totalListeningTime) Listens")
                                .font(.system(size: 12))
                                .foregroundColor(.black)
                            
                            Image(systemName: "headphones.over.ear")
                                .foregroundColor(.black)
                                .font(.system(size: 12))
                            
                            //Self-Note: Another image option is "headphones.sensor.tag.radiowaves.left.and.right" but it looks a little too much as a small icon
                        }
                        
                        HStack {
                            Text("\(wordDemo.totalPractices) Practices")
                                .font(.system(size: 12))
                                .foregroundColor(.black)
                            
                            Image(systemName: "square.and.pencil")
                                .foregroundColor(.black)
                                .font(.system(size: 12))
                        }

                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 10)
                .padding(.horizontal)
            
                Divider()
                    .overlay(Color.black)
            }
            .navigationTitle("Word Bank")
            .background(Color.pink.opacity(0.3))
        }
    }
}

struct WordData {
    var word: String
    var translation: String
    let wordProficiency: String
    let totalListeningTime: Int
    let totalPractices: Int
}

#Preview {
    WordBank()
}
