<p align="center">
	<img src="https://raw.githubusercontent.com/techprimate/tppdf/master/resources/header.png" alt="TPPDF">
</p>

<p align="center">
	<a href="https://github.com/Carthage/Carthage">
		<img src="https://img.shields.io/badge/language-Swift-orange.svg?style=flat-square" alt="Swift"/>
	</a>
	<img src="https://img.shields.io/cocoapods/v/TPPDF.svg?style=flat-square" alt="Cocoapods"/>
	<img src="https://img.shields.io/badge/Carthage-compatible-blue.svg?style=flat-square" alt="Carthage"/>
	<a href="http://cocoapods.org/pods/TPPDF">
		<img src="https://img.shields.io/cocoapods/p/TPPDF.svg?style=flat-square" alt="iOS"/>
	</a>
	<a href="http://cocoapods.org/pods/TPPDF">
		<img src="https://img.shields.io/cocoapods/l/TPPDF.svg?style=flat-square" alt="License"/>
	</a>
	<a href="http://cocoapods.org/pods/TPPDF">
		<img src="https://img.shields.io/cocoapods/dt/TPPDF.svg?style=flat-square" alt="Downloads"/>
	</a>
</p>

<p align="center">
	<a href="https://travis-ci.org/Techprimate/TPPDF">
		<img src="http://img.shields.io/travis/Techprimate/TPPDF.svg?style=flat-square" alt="Travis">
	</a>
	<a href="https://codebeat.co/projects/github-com-techprimate-tppdf-master">
		<img src="https://codebeat.co/badges/ea2a8d79-a50c-43ea-a05a-2ac57baf84de" alt="codebeat">
	</a>
	<a href="https://bettercodehub.com/results/Techprimate/TPPDF">
		<img src="https://bettercodehub.com/edge/badge/Techprimate/TPPDF" alt="bettercodehub">
	</a>
	<a href="https://codecov.io/gh/Techprimate/TPPDF">
		<img src="https://img.shields.io/codecov/c/github/Techprimate/TPPDF.svg?style=flat-square" alt="codecov">
	</a>
</p>

<p align="center">
	<b>
	TPPDF is a fast PDF builder for iOS using simple commands to create advanced documents!
	</b>
</p>

<p align="center">
    <a href="#features">Features</a>
  • <a href="#communication">Communication</a>
  • <a href="#usage">Example</a>
  • <a href="#usage">Usage</a>
  • <a href="#installation">Installation</a>
  • <a href="#credits">Credits</a>
  • <a href="#license">License</a>
</p>

## What's new in 1.1.0?

- Multi-Column Sections

You can now have multiple columns next to each other and add all objects to them!

## Features

- Page header and footer
- Dynamic content layout with page alignment
- Support for tables and cell alignment
- Attributed strings
- Custom spacing
- Image support
- Horizontal line separators
- Custom indentation
- Custom top offset (good for layered rendering)
- Pagination
- Image caption
- Compress images
- Custom image size fit
- Image in the header and footer
- Horizontal line separators in the header and footer
- Generate PDF files directly to handle large PDF files ([Details](http://stackoverflow.com/questions/14691264/how-can-i-lower-memory-climb-when-generating-large-pdfs))
- PDF metadata
- Custom table styling
- Multi-column sections
- You need more features? Checkout #Contribute

## Communication

- If you **need help**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/tppdf). (Tag 'TPPDF')
- If you'd like to **ask a general question**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/tppdf).
- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

## Example

To run the example project, run `pod try TPPDF`

## Usage

Building a PDF document is very easy:

First, you create a document with a paperformat...

```swift
let document = PDFDocument(format: .a4)
```

...then you add your information to a container...

```swift
document.addText(.contentCenter, text: "Create PDF documents easily.")
```

...then you render the document...
 
```swift 
PDFGenerator.generateURL(document: document, filename: "Example.pdf")
```

**...done!**

If you need more details, start here:

### Document creation

You can create a document using a predefined `PDFPageFormat` or by creating a custom `PDFPageLayout`:

```swift
let layout = PDFPageLayout()
let document = PDFDocument(layout: layout)
```
```swift
let document = PDFDocument(format: PDFPageFormat.a4)
```

### Page Layout

The following values can be set to format the page:

- `size` --- width and height of a page
- `margin` --- content inset on each side of a page
- `space.header` --- Space between header and content elements
- `space.footer` --- Space between footer and content elements

All values are in dots and are rendered using 72 DPI (dots per inch), as this is the default screen DPI.

You can also used the predefined formats. For details please refer to the source file [PDFPageFormat.swift](https://github.com/Techprimate/TPPDF/blob/master/Source/PDFPageFormat.swift)

If you need your page in landscape format, use the `landscapeSize` variable.

![Layout](resources/layout.png)

### Elements

TPPDF is element based. When adding any content to the document, you are actually adding an element. Then at the render process all elements are calculated and rendered. But first you need to understand the concept of the layout engine:

### Container

Every element is placed in a specific container. Three containers exist: Header, Content, Footer. Additionally every container has an alignment: Left, Center, Right.

When you add an new element, you need to provide the correct container - the default container is `ContentLeft`, therefore it is an optional parameter. During calculation it will place the element in the correct container and calculate the correct frame accordingly.

A good example would be the following:

```swift
let document = PDFDocument(format: .a4)
document.addText(.footerCenter, text: "Created using TPPDF for iOS.")
```

This command adds the text **Created using TPPDF for iOS** to the footer of all pages, because elements in the header and footer containers are placed on every page.

### Header & Footer

Basically all elements which are either to either a header (`headerLeft`, `headerCenter` or `headerRight`) or footer (`footerLeft`, `footerCenter` or `footerRight`) container, are considered as header and footer elements and will be repeated on each page.

If a page does not have any content, e.g. an empty page in between two pages, the header and footer elements won't be added to this page neither.

### List of element types

... now let's continue with the different kinds of elements.

#### Line Separator

```swift
let style = PDFLineStyle(type: .full, color: UIColor.darkGray, width: 0.5)
document.addLineSeparator(PDFContainer.contentLeft, style: style) 
```

Adds a horizontal line with a specific `style` in the given `container`. This line is affected by the `indentation`, therefore it is possible to change its width by setting a left and a right indentation before. See [Line Style](#LineStyle) for details about the line styling.

#### Simple Text

To add a simple string `text` with a custom `lineSpacing`, you first need to create a `PDFSimpleText` and the an add it to the document.

```swift
let text = "Some text!"
let spacing: CGFloat = 10.0
let textElement = PDFSimpleText(text: text, spacing: spacing)
document.addText(textObject: textElement)
```

For convenience you are also able to add an attributed string directly, and TPPDF will wrap it in a `PDFSimpleText` for you.

```swift
document.addText(text: text, lineSpacing: spacing)
```

During the render process it will create an attributed string using the font set by `setFont(font:)` and the text color set by `setTextColor(color:)`. 

#### Attributed Text

To add an attributed string to the document, you first need to create a `PDFAttributedText` and then add it to the document.

```swift
let attributedTitle = NSMutableAttributedString(string: "Awesome attributed title!", attributes: [
	NSFontAttributeName : UIFont.systemFontOfSize(28.0),
	NSForegroundColorAttributeName : UIColor(red: 219.0 / 255.0, green: 100.0 / 255.0, blue: 58.0 / 255.0, alpha: 1.0)
])
let textElement = PDFAttributedText(text: title)
document.addAttributedText(textObject: attributedTitle)
```

For convenience you are also able to add an attributed string directly, and TPPDF will wrap it in a `PDFAttributedText` for you.

```swift
document.addAttributedText(text: attributedTitle)
```

#### Image

To add an image to the document, you first need to create a `PDFImage` which wraps the image and the customization.

```swift
let image = UIImage(named: "awesome-image")!
let imageElement = PDFImage(image: image)
document.addImage(image: imageElement)
```

A `PDFImage` can also include a optional `caption` which is either a `PDFSimpleText` or `PDFAttributedText`. 
The caption is underneath the image and has the image width as the maximum available width.

If you set a `size` it will try to fit in this size, defaults to `CGSize.zero` which will then use the actual image pixel size. The image can either be scaled to fit the `width` the `height` or both. Adjust this by setting the `sizeFit` to either
 
- `PDFImageSizeFit.width`
- `PDFImageSizeFit.height`
- `PDFImageSizeFit.widthHeight`

To optimize file size, images are resized and compressed using JPEG compression. By default both is enabled, but can change them by setting `options`.

If resizing is enabled, the image will be resized to its frame size in the document.
If compression is enabled, the image will be compressed using the value set in `quality` value. This value is between `0.0` for bad quality and `1.0` for best quality - default is set to `0.85`, which resolves in a good balance between compression and quality.

#### Images in one row

To create a image collage, you can add multiple images in a single row with a `spacing` between them.

Just create an array of `PDFImage` and add them as images in a row. 

```swift
let images = [
    PDFImage(image: UIImage(named: "Image-1.jpg")!, 
             caption: PDFAttributedText(text: NSAttributedString(string: "In this picture you can see a beautiful waterfall!", attributes: captionAttributes))),
    PDFImage(image: UIImage(named: "Image-2.jpg")!,
             caption: PDFAttributedText(text: NSAttributedString(string: "Forrest", attributes: captionAttributes))),
]

document.addImagesInRow(images: images, spacing: 10)
```

#### List

Create a `PDFList` element with the indentation of each level. Each indentation level consists out of a pair of values, `pre` setting the indentation before the list symbol and `past` setting the distance between the symbol and the text.

If you do not provide enough indentation levels, e.g. you only define three but you add an element at the fourth level, the default value `0` will be used for `pre` and `past`.

```swift
let list = PDFList(indentations: [(pre: 0.0, past: 20.0), (pre: 20.0, past: 20.0), (pre: 40.0, past: 20.0)])
```

A list item consists out of a `symbol` and an optional `content`. The symbol is one of the following:

- `PDFListItemSymbol.none`

Doesn't display a symbol before the content

- `PDFListItemSymbol.inherit`

If an item is nested and uses this symbol, it will take the same one as the parent.

- `PDFListItemSymbol.dot`

Symbol is a middle-dot.

- `PDFListItemSymbol.dash`

Symbol is a dash/minus.

- `PDFListItemSymbol.custom(value: String)`

You need to provide any string `value` which will then be used as the symbol. Be sure to set the indentation value correctly, as the indentation is not based on the symbol frame width.

- `PDFListItemSymbol.numbered(value: String?)`

When the parent of multiple list items is of type `numbered` then it will use the index as the symbol, starting with `1` and append a dot `.` to the number.
If you provide `value` this will be used for the parent item, in case you want to override the value.

**Nested Lists**

By adding a list item to another list item you can create nested lists:

```swift
list.addItem(PDFListItem(symbol: .numbered(value: nil))
        .addItem(PDFListItem(content: "Introduction")
            .addItem(PDFListItem(symbol: .numbered(value: nil))
                .addItem(PDFListItem(content: "Text"))
                .addItem(PDFListItem(content: "Attributed Text"))
            ))
        .addItem(PDFListItem(content: "Usage")))
```

Now you have created a multi-level list element, you can add to the document:

```swift
document.addList(list: list)
```

#### Table

Create a `PDFTable` element, which will now be customized.

```swift
let table = PDFTable()
```

Each cell has an optional `content` of type `PDFTableContent`, an optional `style` of `PDFTableCellStyle` and always an `alignment` of `PDFTableCellAlignment`.

##### Alignment

The alignment is one of the following `PDFTableCellAlignment`:

- `topLeft`, `top`, `topRight`
- `left`, `center`, `right`
- `bottomLeft`, `bottom`, `bottomRight`

During calculation the size of the content will be calculated, and afterwards it will be positioned using the cell alignment.

##### Content

A cell content instance `PDFTableCellContent` has a `content` value and a property `type`, which is one of the following:

- `PDFTableContent.none`, empty cell
- `PDFTableContent.string`, a simple string only styled through the cell style
- `PDFTableContent.attributedString`, an attributed string which won't be changed by the cell style
- `PDFTableContent.image`, an image which 

If a cell height is too big for the rest of the page, it will be placed on the next page.

##### Cell Style

To define the style of a cell, you can create the an instance of `PDFTableCellStyle` and directly set it to the cells `style` property, but you can also style a whole table using the property `style` of type `PDFTableStyle` of the `table`.

A cell style defines the `fill` and the `text` color of the content. Also it defines how the `border` is drawn and what `font` should be used:

```swift
let colors = (fill: UIColor.blue, text: UIColor.orange)
let lineStyle = PDFLineStyle(type: .dashed, color: UIColor.gray, width: 10)
let borders = PDFTableCellBorders(left: lineStyle, top: lineStyle, right: lineStyle, bottom: lineStyle)
let font = UIFont.systemFont(ofSize: 20)
let style = PDFTableCellStyle(colors: colors, borders: borders, font: font)
```

An instance of `PDFTableCellBorders` allows you set each border of a cell indvidually. The line style is defined as a `PDFLineStyle` (See [Line Style](#Line-Style)).

To change the style of a specific cell, use the following method of `table`:

```swift
do {
    try table.setCellStyle(row: 1, column: 1, style: PDFTableCellStyle(colors: (fill: UIColor.yellow, text: UIColor.black)))
} catch PDFError.tableIndexOutOfBounds(let index, let length){
    // In case the index is out of bounds

    print("Requested cell is out of bounds! \(index) / \(length)")
} catch {
    // General error handling in case something goes wrong.

    print("Error while setting cell style: " + error.localizedDescription)
}
```

##### Table style

A table style is a collection of cell styles, which will be applied as global values. Take a look at `PDFTableStyleDefaults` where you can find a collection of presets, e.g. `PDFTableStyleDefaults.simple`.

Using the table style you can define the `outline` line style. This will be drawn around the table on each page.

A `PDFTableStyle` lets you set how many rows and columns are considered header cells, and how many rows should be styled as footer rows:

```swift
let style = PDFTableStyle()
style.rowHeaderCount = 3
style.columnHeaderCount = 5
style.footerCount = 1
```

Now the top five rows will be styled using the `style.columnHeaderStyle`, the first three columns will be styled using the `style.rowHeaderStyle` and the very last row will be styled using the `style.footerStyle`.

All other cells are styled using the `style.contentStyle` and if the optional value `style.alternatingContentStyle` is set, then every other row will use this style.

If there are conflicts, e.g a cell is a column and a header row, then the following priority order, with the higher ones beating the lower ones, is used:

- `style.outline` can receive a `PDFLineStyle` to draw table borders. PDFLineStyle can take radius `CGFloat?` propriety to define radius border. This proprity is only used when drawing a rect, like table. 
- `cell.style`, a custom style set for this particular cell
- `style.columnHeaderStyle`, if the cell is a column header therefore in the top rows
- `style.footerStyle`, if the cell is a footer row
- `style.rowHeaderStyle`, if the cell is in the one of the first columns
- `style.alternatingContentStyle`, if the cell is has an odd row index
- `style.contentStyle`, the style every normal cell has

If you set the property `table.showHeadersOnEveryPage` to `true`, the first rows which are the column headers, will be copied and inserted at the top of the table, after each page break.

##### Table generation

First, add your cell data and set the alignment for each cell. This needs to be wrapped in a `try-catch` because it can fail with invalid data or if the validation fails.

The quickest way to generate a new table is using `generateCells(data:, alignments:)`. You need to pass two two-dimensional arrays, one with the data which can be `nil`, `String`, `NSAttributedString`, `Int`, `Double`, `Float` or an `UIImage`. Numbers will be converted into simple strings. Any other content will throw a `PDFError.tableContentInvalid`:

```swift
do {
    try table.generateCells(data: [
        [nil, "Name", "Image", "Description"],
        [1, "Waterfall", UIImage(named: "Image-1.jpg")!, "Water flowing down stones."],
        [2, "Forrest", UIImage(named: "Image-2.jpg")!, "Sunlight shining through the leafs."],
        [3, "Fireworks", UIImage(named: "Image-3.jpg")!, "Fireworks exploding into 100.000 stars"],
        [4, "Fields", UIImage(named: "Image-4.jpg")!, "Crops growing big and providing food."],
        [1, "Waterfall", UIImage(named: "Image-1.jpg")!, "Water flowing down stones."],
        [2, "Forrest", UIImage(named: "Image-2.jpg")!, "Sunlight shining through the leafs."],
        [3, "Fireworks", UIImage(named: "Image-3.jpg")!, "Fireworks exploding into 100.000 stars"],
        [4, "Fields", UIImage(named: "Image-4.jpg")!, "Crops growing big and providing food."],
        [nil, nil, nil, "Many beautiful places"]
    ],
    alignments: [
        [.center, .left, .center, .right],
        [.center, .left, .center, .right],
        [.center, .left, .center, .right],
        [.center, .left, .center, .right],
        [.center, .left, .center, .right],
        [.center, .left, .center, .right],
        [.center, .left, .center, .right],
        [.center, .left, .center, .right],
        [.center, .left, .center, .right],
        [.center, .left, .center, .right],
    ])
} catch PDFError.tableContentInvalid(let value) {
    // In case invalid input is provided, this error will be thrown.

    print("This type of object is not supported as table content: " + String(describing: (type(of: value))))
} catch {
    // General error handling in case something goes wrong.

    print("Error while creating table: " + error.localizedDescription)
}
```

You are also able to create each cell individually, put them in a two-dimensional cell array and assign it to `table.cells` directly. The method above is simply added for convenience.

##### Layout

The table height is defined by its content, but the width is the available space between the indentations.
The width of each column is set by a relative width, defined in an array of values between `0.0` and `1.0` which should sum up to `1.0` being `100%` of the width.

```swift
table.widths = [0.1, 0.3, 0.4, 0.2]
```

Also each cell can have a `margin` which is the distance between the cell frame and its inner borders and the `padding` as the distance between the inner borders and the content.


...and finally you add the table to the document:

```swift
document.addTable(table: table)
```

#### Multi-Column Sections

A multi-column section is a nested container. You create the section with an amount of columns and their relative width, add objects to each column and then add the whole section to the document. 

When adding an object to the section column, you use the Array subscript `section.columns[0]`. You are able to give it an alignment as the first parameter, similar to the `PDFContainer` but only with `.left`, `.center` and `.right` as it is not possible to add a section to the header or footer containers.

```swift
let section = PDFSection(columnWidths: [0.3, 0.4, 0.3])
section.columns[0].addText(.right, text: "right")
section.columns[1].addText(.left, text: "left")
section.columns[2].addText(.center, text: "center")
document.addSection(section)
```

### Helpers

The following methods of `PDFDocument` are not considered as elements, as they are only runtime changes to the calculations and rendering.

#### Space - `addSpace(_ container: PDFContainer, space: CGFloat)`

Adds a space with the height of `space` between the previous element and the next element.

```swift
document.setSpace(space: 32.0)
```

#### Simple Text Font - `setFont(_ container: PDFContainer, font: UIFont)`

Sets the font of a container. This font will be used in all following elements of type `PDFSimpleText` in the given container, until the font is changed. This font does not affect `PDFAttributedText` elements.

```swift
document.setFont(font: UIFont.systemFont(ofSize: 20.0))
```

#### Reset Simple Text Font - `resetFont(_ container: PDFContainer)`

This resets the font to the default font, which is `UIFont.systemFont(ofSize: UIFont.systemFontSize)`

```swift
document.resetFont(.contentLeft)
```

#### Simple Text Color - `setTextColor(_ container: PDFContainer, color: UIColor)`

Sets the font of a container. This font will be used in the next commands in the given container, if there is not a different font specified.

```swift
document.setFont(UIFont.systemFont(ofSize: 20.0))
```

#### Reset Simple Text Color - `resetTextColor(_ container: PDFContainer)`

This resets the font to the default font, which is `UIFont.systemFont(ofSize: UIFont.systemFontSize)`

```swift
document.resetFont(.contentLeft)
```

#### `setIndentation(_ container: PDFContainer, indent: CGFloat, left: Bool)` 

Set the indentation to a given `indent` in the container. By setting `left` to `false` you will change the indentation from the right edge.

```swift
document.setIndentation(indent: 50.0, left: true)
document.setIndentation(indent: 50.0, left: false)
```

Now the document has an indentation of `50` points from left and right edge.
If you need to reset the indentation, call the function with `0.0` as parameter

```swift
document.setIndentation(indent: 0.0)
```

#### `setAbsoluteOffset(_ container: PDFContainer, offset: CGFloat)`

Sets the offset in points from the top edge of a `container` to the given parameter `offset`.

This is useful if you need to layer multiple elements above each other.

#### Page Break

Simply call `document.createNewPage()` and it will add a page break. The next element will be positioned on the next page.

### Styling objects

#### Line Style

A `PDFLineStyle` can have one a line `type`, a `color` and a `width`. The following types are currently impelemented:

- `PDFLineType.none`, invisible line
- `PDFLineType.full`, a full line
- `PFDLineType.dashed`, a dashed line with the dash length and spacing three times the line width
- `PDFLineType.dotted`, a dotted line with the spacing two times the line width

### Pagination

To customize pagination, create an instance of `PDFPagination` and set it to the `pagination` property of your document or simply edit the default one.

Pagination needs one container where it will add the pagination elements on each page. This defaults to `.none` which results in no pagination added.

It is possible to set pagination `range` with a `start` and `end` index. You can also hide specific pages, by adding the page nunber to the `hiddenPages` property. The range is set default to include all pages.
As an example this won't paginate page `1`, `2`, `5` nor any page above `7`:

```swift
let pagination = PDFPagination()
pagination.range = (start: 3, end: 7)
pagination.hiddenPages = [5]
```

To actually define the `style` of the pagination, you can either choose on of the predefined ones, or create a custom closure-based style. The pagination algorithm receives the `current` page number and the `total` pages amount and returns a String, which will then be transformed into an attributed text element, using the attributes in the `textAttributes` dictionary.

#### `.default`

This is the default pagination setting, converts page `1` of `3` to `1 - 3`

#### `.roman(template: String)`

Page `8` of `13` will be converted into roman numerals `VIII` and `XIII` and inserted in the format, e.g `%@ _|_ %@` becomes `VIII _|_ XIII`. The main idea of this preset is converting the numbers into roman numerals but configure the text using the format.

#### `.customNumberFormat(let template, numberFormatter: NumberFormatter)`

Both numbers are converted into a string using the provided `numberFormatter`. This allows you to use the full capabilities of the built-in formatter class. Afterwards both values are also inserted into the provided `template`.

Example:

```swift
let formatter = NumberFormatter.init()
formatter.alwaysShowsDecimalSeparator = true
formatter.numberStyle = .currency
formatter.currencyCode = "EUR"

let template = "%@ + %@"
```

Page `8` of `13` will return the following: `€8.00 + €13.00` which might be completly unsuitable as a pagination, but displays the possibilities. :) 

#### `customClosure(closure: (_ page: Int, _ total: Int) -> String)`

The `closure` will be called everytime the generator needs the pagination value. You have full control on how the resulting string will look like.

Example:

```swift
PDFPaginationStyle.customClosure({ (page, total) -> String in
	let separator: String = {
		switch page % 4 {
			case 1:
				return "#"
			case 2:
				return "&"
			case 3:
				return "*"
			default:
				return "-"
		}
	}()
	return "\(page) " + separator + " \(total)"
})
```

This example will return a different separator, depending on the modulo result.

#### MORE!

If you want a specific style to be included in the presets, please open an issue! The more presets can be provided the better for everyone!

### Document Info

To store metadata information in the document, change the values of the `info` property.
You are able to set a `title`, `author`, `subject` and `keywords`.

If you need to encrypt the document, set an `owner password` and a `user password`. Also you can restrict printing and copying by setting the `allows printing` and `allows copying` flags.

### Generation

You can generate the PDF file using the following method:

```swift
let document: PDFDocument
let filename = "awesome.pdf"

let url = try PDFGenerator.generateURL(document: document, filename: String, progress: { progress in
    print(progress)
}, debug: false)
```

This will render the document to a temporary file and return the URL. Be sure to wrap it a `try-catch` block, as it might throw an error!

It is also possible to render the file and return the data, using `generateData`:

```swift
let document: PDFDocument
let filename = "awesome.pdf"

let data = try PDFGenerator.generateData(document: document, progress: { progress in
    print(progress)
}, debug: false)
```

And if you want to directly save it to a specific file, pass an URL to `generate(document:, to: )`:

```swift
let document: PDFDocument
let url = URL(string: "file://~/Desktop/awesome.pdf")!

try PDFGenerator.generate(document: document, to: url, progress: { progress in
    print(progress)
}, debug: false)
```


## Installation

### Requirements

| Language  | Branch | Pod version | Xcode version | iOS version |
| --------- | ------ | ----------- | ------------- | ----------- |
| Swift 4.1 | [master](https://github.com/techprimate/TPPDF/tree/master) | >= 1.0.x | Xcode 9.3 or greater| iOS 8.3+ |
| Swift 3.0 | [master](https://github.com/techprimate/TPPDF/tree/master) | >= 0.2.x | Xcode 8 or greater| iOS 8.0+ |
| Swift 2.3 | [swift-2.3](https://github.com/techprimate/TPPDF/tree/swift-2.3) | 0.1.5 | Xcode 8, Xcode 7.3.x | iOS 8.0+ |
| Swift 2.2 | [swift-2.2](https://github.com/techprimate/TPPDF/tree/swift-2.3) | 0.1.4 | Xcode 7.3.x | iOS 8.0+ |


### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate TPPDF into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'TPPDF'
end
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate TPPDF into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "Techprimate/TPPDF" ~> 1.0
```

Run `carthage update` to build the framework and drag the built `Alamofire.framework` into your Xcode project

### Swift Package Manager

Swift Package Manager is not supported, as TPPDF requires the framework `UIKit` which is not available on macOS or Linux.

### Manually

If you prefer not to use either of the aforementioned dependency managers, you can integrate TPPDF into your project manually.

#### Embedded Framework

- Open up Terminal, `cd` into your top-level project directory, and run the following command "if" your project is not initialized as a git repository:

```bash
$ git init
```

- Add TPPDF as a git [submodule](http://git-scm.com/docs/git-submodule) by running the following command:

```bash
$ git submodule add https://github.com/Techprimate/TPPDF.git
```

- Open the new `TPPDF` folder, and drag the `TPPDF.xcodeproj` into the Project Navigator of your application's Xcode project.

    > It should appear nested underneath your application's blue project icon. Whether it is above or below all the other Xcode groups does not matter.

- Select the `TPPDF.xcodeproj` in the Project Navigator and verify the deployment target matches that of your application target.
- Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
- In the tab bar at the top of that window, open the "General" panel.
- Click on the `+` button under the "Embedded Binaries" section.
- You will see two different `TPPDF.xcodeproj` folders each with two different versions of the `TPPDF.framework` nested inside a `Products` folder.

    > It does not matter which `Products` folder you choose from, but it does matter whether you choose the top or bottom `TPPDF.framework`. 
    
- Select the top `TPPDF.framework` for iOS and the bottom one for OS X.

    > You can verify which one you selected by inspecting the build log for your project. The build target for `TPPDF` will be listed as either `TPPDF iOS` or `TPPDF OSX`.

- And that's it!

> The `TPPDF.framework` is automagically added as a target dependency, linked framework and embedded framework in a copy files build phase which is all you need to build on the simulator and a device.

## Apps using TPPDF

If you are using TPPDF in your app and want to be listed here, simply create a pull request or let me know on twitter or via github. I am always curious who is using my projects :)

[Hikingbook](https://itunes.apple.com/app/id1067838748) - by Zheng-Xiang Ke

<img src="https://raw.githubusercontent.com/techprimate/tppdf/master/resources/apps/Hikingbook.png" alt="Hikingbook"/>

[Bug Journal](https://itunes.apple.com/us/app/bug-journal/id1232077952) - by David Johnson

<img src="https://raw.githubusercontent.com/techprimate/tppdf/master/resources/apps/Bug_Journal.png" alt="Bug Journal"/>

[Energy Tracker](https://itunes.apple.com/de/app/energy-tracker/id1193010972) - by Stefan Nebel

<img src="https://raw.githubusercontent.com/techprimate/tppdf/master/resources/apps/EnergyTracker.jpg" alt="Energy Tracker"/>

[Mama's Cookbook (future release)](https://itunes.apple.com/us/app/mamas-cookbook/id1019090528) - by Philip Niedertscheider

<img src="https://raw.githubusercontent.com/techprimate/tppdf/master/resources/apps/MCB.png" alt=MCB"/>

## Credits

TPPDF is created by Philip Niedertscheider, owned by [techprimate](https://www.github.com/techprimate)

<p align="center">
	<a href="https://www.techprimate.com">
		<img src="https://img.shields.io/badge/www-techprimate.com-blue.svg?style=flat-square" alt="techprimate.com">
	</a>
	<a href="http://twitter.com/techprimate">
	    <img src="https://img.shields.io/badge/twitter-@Techprimate-blue.svg?style=flat-square" alt="twitter">
	</a>
	<a href="https://facebook.com/techprimate">
		<img src="https://img.shields.io/badge/facebook-@Techprimate-blue.svg?style=flat-square" alt="facebook">
	</a>
</p>


### Contributors

- Philip Niedertscheider, [techprimate-phil](https://www.github.com/techprimate-phil)
- Zheng-Xiang Ke, [kf99916](https://www.github.csom/kf99916)
- Marco Betschart, [marbetschar](https://github.com/marbetschar)

### Thank You

Special thanks goes to **Nutchaphon Rewik** for his project [SimplePDF](https://github.com/nRewik/SimplePDF) for the inspiration.

## License

TPPDF is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
