//
//  ColoringPanelView.swift
//  Milton-Coloring
//
//  Created by Stefanita Oaca on 18.07.2024.
//

import SwiftUI

struct ColoringPanelView: View {
    
    @ObservedObject var viewModel: ColoringPanelViewModel
    
    var body: some View {
        ZStack{
            GeometryReader { geometry in
                ZStack{
                    Image(uiImage: viewModel.backgroundImage)
                        .resizable()
                    VStack{
                        Button {
                            
                        } label: {
                            Image(uiImage: viewModel.doneButton)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                        .frame(width: geometry.size.width * 0.8)
                        
                        if viewModel.colorinPanelType == .dippers{
                            HStack{
                                VStack{
                                    Spacer()
                                        .frame(height: geometry.size.height * 0.05)
                                    VStack(alignment: .leading){
                                        Spacer()
                                        ForEach(Array(viewModel.getDippers().split().left.enumerated()), id: \.offset){ index, dipper in
                                            HStack(){
                                                if index != viewModel.selectedDipper{
                                                    Spacer()
                                                        .frame(width: geometry.size.width * 0.1)
                                                }
                                                
                                                Button {
                                                    withAnimation {
                                                        viewModel.selectedDipper(index)
                                                    }
                                                } label: {
                                                    Image(uiImage: dipper)
                                                        .resizable()
                                                        .frame(width: geometry.size.width * 0.35, height: geometry.size.width * 0.35)
                                                        .aspectRatio(contentMode: .fit)
                                                }
                                                
                                                
                                            }
                                            Spacer()
                                        }
                                    }
                                    Spacer()
                                        .frame(height: geometry.size.height * 0.05)
                                }
                                VStack{
                                    Spacer()
                                        .frame(height: geometry.size.height * 0.05)
                                    VStack(alignment:.trailing){
                                        Spacer()
                                        ForEach(Array(viewModel.getDippers().split().right.enumerated()), id: \.offset){ index, dipper in
                                            HStack{
                                                Spacer()
                                                Button {
                                                    withAnimation {
                                                        viewModel.selectedDipper(viewModel.getDippersCount() / 2 + index)
                                                    }
                                                } label: {
                                                    Image(uiImage: dipper)
                                                        .resizable()
                                                        .frame(width: geometry.size.width * 0.35, height: geometry.size.width * 0.35)
                                                        .aspectRatio(contentMode: .fit)
                                                }
                                                if index != viewModel.selectedDipper - viewModel.getDippersCount() / 2{
                                                    Spacer()
                                                        .frame(width: geometry.size.width * 0.1)
                                                }
                                            }
                                            Spacer()
                                        }
                                    }
                                    Spacer()
                                        .frame(height: geometry.size.height * 0.05)
                                }
                            }
                            .frame(width: geometry.size.width * 0.65)
                        }else{
                            ZStack{
                                VStack{
                                    Spacer()
                                    
                                    HStack{
                                        if viewModel.selectedCrayon != 0{
                                            Spacer()
                                        }
                                        Button {
                                            withAnimation {
                                                viewModel.selectedCrayon = 0
                                            }
                                        } label: {
                                            Image(uiImage: viewModel.eraserImage)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: geometry.size.width * 0.8)
                                        }
                                        
                                        Spacer()
                                    }
                                    Spacer()
                                    ForEach(Array(viewModel.getCrayons().enumerated()), id: \.offset){ index, crayon in
                                        HStack{
                                            if viewModel.selectedCrayon - 1 != index{
                                                Spacer()
                                            }
                                            Button {
                                                withAnimation {
                                                    viewModel.selectedCrayon(1 + index)
                                                }
                                            } label: {
                                                Image(uiImage: crayon)
                                                    .resizable()
                                                    .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.06)
                                                    .aspectRatio(contentMode: .fill)
                                            }
                                            Spacer()
                                        }
                                        Spacer()
                                    }
                                }
                                HStack{
                                    Spacer()
                                    ZStack(alignment: .trailing){
                                        Image(uiImage: viewModel.foregroundImage)
                                            .resizable()
                                            .frame(width: geometry.size.width * 0.65)
                                        VStack{
                                            Spacer()
                                                .frame(height: geometry.size.height * 0.05)
                                            HStack{
                                                Spacer()
                                                VStack{
                                                    Spacer()
                                                    ForEach(Array(viewModel.getDippers().enumerated()), id: \.offset){ index, dipper in
                                                        HStack{
                                                            if viewModel.selectedDipper - 1 != index{
                                                                Spacer()
                                                            }
                                                            Button {
                                                                withAnimation {
                                                                    viewModel.selectedDipper(1 + index)
                                                                }
                                                            } label: {
                                                                Image(uiImage: dipper)
                                                                    .resizable()
                                                                    .frame(width: geometry.size.width * 0.35, height: geometry.size.width * 0.35)
                                                                    .aspectRatio(contentMode: .fit)
                                                            }
                                                            if viewModel.selectedDipper - 1 == index{
                                                                Spacer()
                                                            }
                                                            Spacer()
                                                                .frame(width: geometry.size.width * 0.065)
                                                        }
                                                        Spacer()
                                                    }
                                                }
                                            }
                                            Spacer()
                                                .frame(height: geometry.size.height * 0.05)
                                        }
                                        .frame(width: geometry.size.width * 0.55)
                                    }
                                }
                            }
                        }
                        
                        ZStack{
                            HStack{
                                VStack{
                                    if viewModel.colorinPanelType != .regular{
                                        Spacer()
                                            .frame(height: geometry.size.height * 0.05)
                                    }
                                    Button {
                                        withAnimation {
                                            viewModel.changeMode()
                                        }
                                    } label: {
                                        Image(uiImage: viewModel.regularButton)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    }
                                    if viewModel.colorinPanelType == .regular{
                                        Spacer()
                                            .frame(height: geometry.size.height * 0.05)
                                    }
                                }
                                Spacer()
                            }
                            
                            
                            VStack{
                                if viewModel.colorinPanelType != .patterns{
                                    Spacer()
                                        .frame(height: geometry.size.height * 0.05)
                                }
                                Button {
                                    withAnimation {
                                        viewModel.changeMode()
                                    }
                                } label: {
                                    Image(uiImage: viewModel.patternsButton)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                }
                                if viewModel.colorinPanelType == .patterns{
                                    Spacer()
                                        .frame(height: geometry.size.height * 0.05)
                                }
                            }
                            
                            HStack(){
                                Spacer()
                                VStack{
                                    if viewModel.colorinPanelType != .dippers{
                                        Spacer()
                                            .frame(height: geometry.size.height * 0.05)
                                    }
                                    Button {
                                        withAnimation {
                                            viewModel.changeMode()
                                        }
                                    } label: {
                                        Image(uiImage: viewModel.regularButton)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    }
                                    if viewModel.colorinPanelType == .dippers{
                                        Spacer()
                                            .frame(height: geometry.size.height * 0.05)
                                    }
                                }
                            }
                        }
                        .frame(height: 0.2 * geometry.size.height)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height * 1.1)
            }
        }
        .ignoresSafeArea()
    }
}
