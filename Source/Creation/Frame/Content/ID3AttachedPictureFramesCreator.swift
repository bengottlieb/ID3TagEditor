//
//  ID3AttachedPictureFramesCreator.swift
//
//  Created by Fabrizio Duroni on 26/02/2018.
//  2018 Fabrizio Duroni.
//

import Foundation

class ID3AttachedPictureFramesCreator: ID3FrameCreatorsChain {
    private let id3FrameConfiguration: ID3FrameConfiguration
    private let id3AttachedPictureFrameConfiguration: ID3AttachedPictureFrameConfiguration
    private let frameContentSizeCalculator: FrameContentSizeCalculator
    private let frameFlagsCreator: FrameFlagsCreator

    init(id3FrameConfiguration: ID3FrameConfiguration,
         id3AttachedPictureFrameConfiguration: ID3AttachedPictureFrameConfiguration,
         frameContentSizeCalculator: FrameContentSizeCalculator,
         frameFlagsCreator: FrameFlagsCreator) {
        self.id3FrameConfiguration = id3FrameConfiguration
        self.id3AttachedPictureFrameConfiguration = id3AttachedPictureFrameConfiguration
        self.frameContentSizeCalculator = frameContentSizeCalculator
        self.frameFlagsCreator = frameFlagsCreator
    }

    override func createFrames(id3Tag: ID3Tag, tag: [UInt8]) -> [UInt8] {
        if let attachedPictures = id3Tag.attachedPictures {
            var frames: [UInt8] = []
            for attachedPicture in attachedPictures {
                var frame: [UInt8] = id3FrameConfiguration.identifierFor(frameType: .AttachedPicture, version: id3Tag.version)
                var contentAsBytes: [UInt8] = [UInt8]()
                contentAsBytes.append(contentsOf: getAttachedPictureHeaderFor(
                        attachedPicture: attachedPicture,
                        version: id3Tag.version,
                        format: attachedPicture.format
                ))
                contentAsBytes.append(contentsOf: [UInt8](attachedPicture.art));
                frame.append(contentsOf: frameContentSizeCalculator.calculateSizeOf(content: contentAsBytes, version: id3Tag.version))
                frame.append(contentsOf: frameFlagsCreator.createFor(version: id3Tag.version))
                frame.append(contentsOf: contentAsBytes)
                frames.append(contentsOf: frame)
            }
            return tag + frames
        }
        return super.createFrames(id3Tag: id3Tag, tag: tag)
    }

    private func getAttachedPictureHeaderFor(attachedPicture: AttachedPicture,
                                             version: ID3Version,
                                             format: ID3PictureFormat) -> [UInt8] {
        var header = id3AttachedPictureFrameConfiguration.getHeaderMimeTypeFor(pictureFormat: format, version: version)
        let coverTypeBytePosition = id3AttachedPictureFrameConfiguration.getPictureTypeBytePositionFor(
                pictureFormat: format,
                version: version
        )
        header[coverTypeBytePosition] = attachedPicture.type.rawValue
        return header
    }
}
