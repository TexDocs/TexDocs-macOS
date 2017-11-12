//
//  TCPClient.swift
//  SourceCodeView
//
//  Created by Noah Peeters on 12.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

open class TCPClient: NSObject, StreamDelegate {
    //MARK: Properties
    var inputStream: InputStream!
    var outputStream: OutputStream!
    var maxBufferSize: Int = 1024
    
    //MARK: functions
    public final func initNetworkCommunication(host: CFString, port: UInt32) {
        var readStream:  Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(nil, host, port, &readStream, &writeStream)

        self.inputStream = readStream!.takeRetainedValue()
        self.outputStream = writeStream!.takeRetainedValue()
        
        self.inputStream.delegate = self
        self.outputStream.delegate = self
        
        self.inputStream.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        self.outputStream.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        
        self.inputStream.open()
        self.outputStream.open()
    }
    
    public final func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode{
        case Stream.Event.openCompleted:
            if outputStream == aStream{
                self.outputStreamOpened()
            } else {
                self.inputStreamOpened()
            }
        case Stream.Event.hasSpaceAvailable:
            if outputStream == aStream {
                self.outputStreamReady()
            }
        case Stream.Event.hasBytesAvailable:
            if aStream == inputStream{
                var buffer = [UInt8](repeating: 0, count: self.maxBufferSize)
                var length: Int!
                
                while (inputStream.hasBytesAvailable) {
                    length = inputStream.read(&buffer, maxLength: self.maxBufferSize)
                    if length > 0 {
                        let data: Data = Data(bytes: &buffer, count: length)
                        onReceive(data: data)
                    }
                }
            }
        case Stream.Event.errorOccurred:
            self.error()
        case Stream.Event.endEncountered:
            aStream.close()
            aStream.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
            self.closed()
        default: break
        }
    }
    
    //MARK: Interface
    public func setBufferSize(maxBufferSize: Int) {
        self.maxBufferSize = maxBufferSize
    }
    
    public final func send(data: Data) {
        self.outputStream.write(UnsafePointer<UInt8>(Array(data)), maxLength: data.count)
    }
    
    public final func send(bytes: [UInt8]) {
        self.outputStream.write(UnsafePointer<UInt8>(bytes), maxLength: bytes.count)
    }
    
    //MARK: Callbacks
    open func onReceive(data: Data) {}
    
    open func outputStreamOpened() {}
    
    open func inputStreamOpened() {}
    
    open func outputStreamReady() {}
    
    open func error() {}
    
    open func closed() {}
}
