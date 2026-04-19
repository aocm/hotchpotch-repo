package com.example.app;

import com.example.legacy.LegacyGreeter;

public class Main {

    public static void main(String[] args) {
        LegacyGreeter greeter = new LegacyGreeter();
        System.out.println(greeter.greet("Nexus-managed dependency"));
    }
}
