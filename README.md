# Peer2Gether

## Description

This project aims to create an application that connects devices in peer to peer in order to listen 
to music simultaneously for every user connected to the same room. It is close to what watch2Gether 
does with youtube videos without the peer to peer part.

<details>
    <summary>What is Watch2Gether ?</summary>
    Watch2Gether has a simple goal: to make it easy for friends to watch videos together, no matter 
    where they are in the world. The whole idea of Watch2Gether is to give you a cool place where 
    you can relax and have fun with your friends. Enjoy Watch2Gether!
</details>

## Frameworks used

For this project we decided to go with flutter that is a Dart framework used to develop mostly
mobile applications that is versatile and allows to have one code for both ios and android.
Its portability was really important for us.

We use WebRTC on this project. WebRTC is a peer to peer protocol that is widely used and known for
its robustness.
Its reliability was what we were looking for.

## Installation

### Dependencies

- flutter 2.7.0 - 3.0

```bash
git clone https://github.com/PoCInnovation/Peer2Gether
cd Peer2Gether/App
flutter build
flutter run
```

## Features

Once in the app, you can create a room by clicking the :heavy_plus_sign: button in the top right 
corner, name it, set the max amount of people that can join it, then go ahead and click on create.

You can join a room by clicking on it and the owner of the room can see your request to join the 
room and accept it.

## Maintainers

- [Alexandre Collin-Bétheuil](https://github.com/EpitAlexandre)
- [Benjamin Reigner](https://github.com/Breigner01)
- [Nicolas Heude](https://github.com/nicolasheude)
- [Quentin Fringhian](https://github.com/QuentinFringhian)