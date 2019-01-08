# GW-master2

## Introduction

**1.1. Overview**

GW is an application for supporting Metso sales team in estimating grinding power under diverse conditions. It provides you with a portable power estimation and graphical model which is faster and easier than previously used technologies in the field.  The developed application accompanied by an updated package of documents which covers the whole cycle of software lifetime so far.

The application is designed and implemented in Research, Technology Development and Engineering team of Grinding Media. Right now, we have an iOS version of this which will be distributed to limited group of Metso people for the user acceptance test. This version demonstrates the key features and will be extended after collecting feedback from our end users.

In this document, we simply explain how you can use this application in a step by step description of the service. We provide points of contact for troubleshooting purposes, a summary of the system and then cover the functionality of each screen.
 
You can click on the name of the application in the entire of this document to access the most current version of the …. 


**1.2.	Points of Contacts**

Contact our team for information and troubleshooting purposes through:
Telephone:
Email:



## Getting Started

**2.1.	Launch Screen**

> It is the Launch Screen or the Splash Screen where gives the very quick information about Our company and app name, and lead to the Welcome Screen automatically.

<p align="center">
  <img src="https://github.com/ElnazTaqizadeh/GW-master2/blob/master/Images/Screen%20Shot%202017-11-20%20at%201.19.17%20PM.png" width="350"/>
</p>

**2.2.	Welcome Screen**

> This screen will give a break and space between the main “Input Form Screen” and the “Launch Screen”. Just a simple “Start” button at right top of the screen to make it simple and easy to work with. Tapping on this button, navigates you to the Input page where the real action occurs.

<p align="center">
  <img src="https://github.com/ElnazTaqizadeh/GW-master2/blob/master/Images/Screen%20Shot%202017-11-20%20at%2012.03.21%20PM.png" width="350"/>
</p>


**2.3.	Input Form Screen**

>Regarding to the technical criteria which our team has developed, a form is designed to get the appropriate inputs for the demanded results. Each field requires a parameter that would be needed in order to run the specific mathematical function in which calculates the approximation. The parameters are defined in each field and the Units are all in the SI metrics system (as you can see in front of their name in each row). In the case of default value for a parameter you can see at the end of its definition.
>_You can find out the parameters of form, their definition and units in the following table._

| Parameter | Description | Unit |
| --- | --- | --- |
| Name | Mill name | - |
| phi | Mill speed, Percent critical | - |
| D | Mill diameter |  m |
| L | Effective mill length | m |
| J |  Percent mill fill | - |
| Jb | Percent mill ball fill | - |
| l_l | Lifter height | m |
| betha_lifter | Lifter angle | Degrees |
| chargeDensity  | Mill charge density | kg/m^3 |
| slurryDensity | Slurry density | kg/m^3 |
| Ai | Bond abrasion index | - |
| discharge_is_grate | Grate discharge:  Switch On , Overflow : Off | - |
| F80 | Feed size | m |
| Db | Top up media size| m |
| P_measured | Measured power | kW |

>Description of actions:
>1.	User will fill out the parameters empty fields with the right amounts.
>2.	User will tap the “apply” button on the top right side of the screen in order to get the program run and get the results.
>3.	A “Restart” button feature that will give the potential possibility of clearing all the fields and rerun the process. 

<p align="center">
  <img src="https://github.com/ElnazTaqizadeh/GW-master2/blob/master/Images/Screen%20Shot%202017-11-20%20at%2012.03.37%20PM.png" width="350"/>
</p>

**2.4.	Result Screen**


>This screen shows the graphical diagram of Power model plus the numeric results. There will be a diagram of Power model, the estimated numeric Power result and some specific inputs (on the incoming updated versions) on the screen.
>
>Description of actions:
>
>Again, the is a “Restart” button with the same functionality as the last screen--will reset the input fields to rerun with new inputs.
>And a “Share” button of IOS in the right top of screen where you can share the results via SMS service, Email or any other given option and/or you can save the screen image into your photo library.
>Sequence of screens:

<p align="center">
  <img src="https://github.com/ElnazTaqizadeh/GW-master2/blob/master/Images/Screen%20Shot%202017-11-20%20at%2012.03.47%20PM.png" width="350"/>
</p>


>Result Screen followed with the sharing action screen if you decide to hit the “share” button (As you can see in the following figure).

<p align="center">
  <img src="https://github.com/ElnazTaqizadeh/GW-master2/blob/master/Images/Screen%20Shot%202017-11-20%20at%2012.04.02%20PM.png" width="350"/>
</p>



_For more details of the whole procedure you can take look at the presentation of the application on November 2, 2017._
