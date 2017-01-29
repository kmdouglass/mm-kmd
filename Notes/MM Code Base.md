# General Notes on Micro-Manager

## Programming

### MMCore documentation

https://valelab4.ucsf.edu/~MM/doc/MMCore/html/index.html

### The Circular Buffer

Micro-Manager's circular buffer is a sort of "temporary" holding zone
for images arriving from the camera before the MMCore can process
them.

+ The Circular Buffer is implemented in C++ as a std::vector of
  FrameBuffer
  objects. (https://valelab4.ucsf.edu/svn/micromanager2/trunk/MMCore/CircularBuffer.h)
  Therefore, the functionality of the the CircularBuffer is very much
  the same as std::vector (within in the limits of what the class
  allows).

#### CircularBuffer::Initialize(...)

This is **not** the constructor for CircularBuffer. It initializes the
buffer to prep it to receive images.

```c++
insertIndex_ = 0;
saveIndex_ = 0;
overflow_ = false;
```

Resets the indexes for accessing data in the circular buffer.

```c++
frameArray_.resize(cbSize);
for (unsigned long i=0; i<frameArray_.size(); i++)
{
   frameArray_[i].Resize(w, h, pixDepth);
   frameArray_[i].Preallocate(numChannels_, numSlices_);
}
```

I think the above might be responible for `GetTopImage()` not
returning 0 and raising an error like `GetNextImage()`. If
`CircularBuffer.Initialize()` is called before an acquisition is
begun, then `frameArray_.Preallocate(...)` will be called and
`frameArray_.size()` will not return 0.

Where/when is `CircularBuffer.Initialize(...)` called?

#### CircularBuffer::GetTopImage()

```c++
const unsigned char* CircularBuffer::GetTopImage() const
{
   MMThreadGuard guard(g_bufferLock);

   if (frameArray_.size() == 0)
      return 0;

   if (insertIndex_ == 0)
      return frameArray_[0].GetPixels(0, 0);
   else
      return frameArray_[(insertIndex_-1) % frameArray_.size()].GetPixels(0, 0);
}
```

`frameArray_` is a std::vector of FrameBuffer objects, so indexing
into `frameArray_` returns one of these. FrameBuffers must then have a
`GetPixels()` method.

The key is that it uses a private variable known as `insertIndex_` to
index into the array. `insertIndex_` is initialized to zero in the
CircularBuffer's constructor. There is also a `saveIndex_` that is
initalized to zero as well. `saveIndex_` keeps track of images in the
order in which they were put into the buffer (like FIFO
behavior). `insertIndex_` keeps track of the most recent image.

Like `GetNextImage()`, `GetTopImage()` appears to return a pointer to
the pixel data. (The `GetPixels` method seems like it should return a
const unsigned char*.)

**Why is the buffer "circular"???** I think this is because of the
  modulo operation when indexing into `frameArray_`. If `insertIndex`
  becomes too large, it will wrap back to zero.

#### GetNextImage()

```c++
const unsigned char* CircularBuffer::GetNextImage()
{
   MMThreadGuard guard(g_bufferLock);

   if (saveIndex_ < insertIndex_)
   {
      const unsigned char* pBuf = frameArray_[(saveIndex_) % frameArray_.size()].GetPixels(0, 0);
      saveIndex_++;
      return pBuf;
   }
   return 0;
}
```

This is what allows MMCoreJ's popNextImage() to work. It uses the
`saveIndex_` counter to keep track of what images have been already
been popped out of the buffer.

#### CircularBuffer::InsertMultiChannel(...)

This is also called by CircularBuffer::InsertImage(...) to insert a
single image into the buffer.

`insertIndex_` is incremented by one each time an image is inserted
into the CircularBuffer. This is what allows `GetTopImage()` to access
the most recently-created image.

#### CircularBuffer:Clear()

This is fully defined in CircularBuffer.h, not CircularBuffer.cpp. It
simply resets the `insertIndex_` and `saveIndex_` values to zero.

I think that **this behavior explains why mmc.getLastTaggedImage()**
will return an image after calling `mmc.clearCircularBuffer()`. The
image is never really removed from the circular buffer; rather,
indexes pointing to various images in the buffer are
incremented/decremented.

#### Further Reading

+ **Docs** (mostly undocumented) https://valelab4.ucsf.edu/~MM/doc/MMCore/html/class_circular_buffer.html
+ **Source Code** https://valelab4.ucsf.edu/svn/micromanager2/trunk/MMCore/CircularBuffer.cpp

### Image/Frame Buffers

Image and Frame buffer code is found in *MMDevice/ImgBuffer.cpp* from
the MM root code directory.

#### Further Reading

+ **Docs** https://valelab4.ucsf.edu/~MM/doc/MMDevice/html/class_img_buffer.html
