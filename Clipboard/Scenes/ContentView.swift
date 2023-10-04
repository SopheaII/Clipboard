//
//  ContentView.swift
//  Test_MenuBar_Mac
//
//  Created by Sao Sophea on 3/10/23.
//

import SwiftUI
import AppKit

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var data:[String] = []
    @State private var searchText = ""
    @State var previousClipText = ""
    @State private var isShowDetail = false
    @State private var detailData = ""
    @State private var isScrollToTop = false
    @State private var hoverIndex = -1
    
    var searchResults: [String] {
            if searchText.isEmpty {
                return data
            } else {
                return data.filter { $0.lowercased().contains(searchText.lowercased()) }
            }
        }
    
    func startTriggerCopy(){
        data = UserDefaultUtils.shared.getDataList()
        previousClipText = data.isEmpty ? "" : data[0]
        
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {[self] _ in
            self.updateClipboardText()
        }
        timer.tolerance = 0.1
        RunLoop.main.add(timer, forMode: .common)
    }

    func updateClipboardText() {
        if let clipboardString = NSPasteboard.general.string(forType: .string), previousClipText != clipboardString {
            data = data.filter{$0 != clipboardString}
            self.data.insert(clipboardString, at: 0)
            self.previousClipText = clipboardString
            isScrollToTop.toggle()
            /// Limit data for 100
            if data.count == 100 {
                data.remove(at: data.count - 1)
            }
            updateDataToUserDefault()
        }
    }
    
    func updateDataToUserDefault() {
        UserDefaultUtils.shared.storeDataList(data: data)
    }
    
    func removeItem(index: Int) {
        data.remove(at: index)
        updateDataToUserDefault()
    }
    
    func copyFromList(text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        previousClipText = text
    }
    
    func clearAll(){
        data.removeAll()
        copyFromList(text: "")
        updateDataToUserDefault()
    }
    
    var body: some View {
        VStack(alignment: .leading){
            
            VStack(alignment: .leading){
                if !isShowDetail {
                    Text("Clipboard History")
                        .font(.title)
                        .foregroundColor(Color("fontColor"))
                        .frame(maxWidth: .infinity, alignment: .center)
                    TextField("search", text: $searchText)
                        .textFieldStyle(.roundedBorder)

                    ScrollView(.vertical, showsIndicators: false, content: {
                        ScrollViewReader{ scrollViewProxy in
                            VStack(alignment: .leading, spacing: 5) {
                                Spacer().frame(height: 5).id(1)
                                ForEach(Array(searchResults.enumerated()), id: \.element) {index, item in
                                    HStack {
                                        Button {
                                            copyFromList(text: item)
                                        } label: {
                                            Text(item)
                                                .lineLimit(1)
                                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                        }
                                        .background(hoverIndex == index ? Color.blue : .clear)
                                        .cornerRadius(5)
                                        .onHover(perform: { hovering in
                                            hoverIndex = hovering ? index : -1
                                        })
                                        Button(action: {
                                            isShowDetail = true
                                            detailData = item
                                        }){
                                            Image(systemName: "eye")
                                                .resizable()
                                                .frame(width: 17, height: 12)
                                        }
                                        .padding(3)
                                        .buttonStyle(PlainButtonStyle())
                                        Button(action: {
                                            removeItem(index: index)
                                        }){
                                            Image(systemName: "trash.slash")
                                                .resizable()
                                                .frame(width: 13, height: 16)
                                                .foregroundColor(Color("deleteColor"))
                                        }
                                        .padding(3)
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                            .onChange(of: isScrollToTop) { newValue in
                                scrollViewProxy.scrollTo(1)
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        }
                    })
                    .frame(height: 280)
                }else {
                    Button(action: {
                        isShowDetail = false
                    }){
                        Image(systemName: "arrow.left")
                            .resizable()
                            .frame(width: 17, height: 12)
                            .foregroundColor(Color("deleteColor"))
                    }
                    .padding(5)
                    ScrollView {
                        Text("\(detailData)")
                            .foregroundColor(Color("fontColor"))
                            .textSelection(.enabled)
                    }
                    .frame(height: 350)
                }
                Spacer()
                HStack {
                    Button(action: {
                        clearAll()
                    }) {
                        Text("Clear all")
                    }
                    Spacer()
                    Button(action: {
                        exit(-1)
                    }) {
                        Text("Quit App")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: 350)
            .padding(10)
            .background(Color("background"))
            .onAppear{
                startTriggerCopy()
            }
        }
            
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(width: 400)
    }
}
