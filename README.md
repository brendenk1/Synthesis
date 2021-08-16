# Synthesis

noun: The combination of ideas to form a theory or system.

After working with Apple's native frameworks Combine and SwiftUI, several different state and data flow ideas have been suggested and tried. 

Two main objectives to this system:
* Single source of truth over time
* Consistent, reliable data flow

While nothing here is novel, it is a selection of various approaches distilled to a single method.

## Components

* Action 

noun: the fact or process of doing something, typically to achieve an aim

These objects are responsible for connecting a Kernel to a Connector object

* Connector 

noun: a thing which links two or more things together

 These objects are responsible for connecting outside sources to a subscription via a publisher

* ErrorSubscription

_subscription_ noun: the action of making or agreeing to make an advance payment in order to receive something

This specialized Subscription is a part of `Combine.Subscribers` that allow for the receipt of errors

* Format

noun: a defined structure for the processing or display of data

These objects provide definitions on how to present data 

* Kernel

noun: the most basic level or core

These objects represent the source of truth over time

* Manager 

noun: a system that controls or organizes processes

These objects represent formatted values for presentation

## Diagram

+-------------------------------------------------------------------------+
|                                                                         |
|                                                                         |
|                                     +--------------------- UI           |
|                                     |                      ^            |
|                                     |                      |            |
|                                     +--------------------- Manager      |
|                                     |                      ^            |
|                                     v                      |            |
|                                   Action                   Format       |                           
|                                     |                      ^            |
|                                     v                      |            |
|       Outside Sources ----------> Connector -------------> Kernel       |
|                                                                         |
|                                                                         |
|                                                                         |
+-------------------------------------------------------------------------+

