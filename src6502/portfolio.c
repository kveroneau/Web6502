#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "web6502.h"
#include "dom6502.h"
#include "webdisk6502.h"
#include "router6502.h"

// This is a nice helper function to render basic content.
void SetContent(char* title, char* fname){
    SetTimer(); // Turn of real-time mode, so DOM elements can render.
    SetTo(title, 2); // Set the sub-title to the passed in text string.
    WD_LoadMarkdown(fname, "content"); // Load a Markdown file from a compatible WebDisk.
}

// Used for testing, will not be part of production release of Portfolio.
void DoTest(){
    SetContent("A Test Route has been tested!", "test.md");
}

// Our main function, C's entry point.
void main(){
    char r; // Define our result variable, cc65 does not allow define and assign together.
    SetTo("Portfolio is starting, please wait...", 2); // Let the visitor know where we're at.
    InitRouter(1); // Initialize the WebRouter on Card Slot #1.
    InitWebDisk(7); // Initialize a WebDisk compatible card on Card Slot #7.
    r = WD_LoadTextFile("Main.Menu", "menu"); // Load our menu snippet from the WebDisk into DOM ID `menu`.
    if (r == 255){ SetTo("Unable to load menu document!", 2); } // Did it load?
    r = CheckRoute(); // Check if the visitor came in with a route of their own?
    if (r == 0){
        PushRoute("/Welcome"); // No route from visitor, push them to the welcome route.
    }
    while (1){ // Loop to manage our Portfolio events for the life-cycle of the application.
        SetRealTime(); // Set Web6502 to use real-time mode to make the site more snappy.
        r = RouteSet(); // Check to see if a Route has been requested by the visitor?
        if (r != 0){
            SetTo("Loading...", 2); // Visitor requested route, let's let them know we're loading it.
            if (strcmp(URL, "/Welcome") == 0){ SetContent("Welcome to my Online Portfolio!", "Welcome.Page"); }
            else if (strcmp(URL, "/HowItWorks") == 0){ SetContent("How does this site work anyways?", "AboutSite.Page"); }
            else if (strcmp(URL, "/PortfolioSource") == 0){ SetContent("Source Code for this site", "portfolio.c"); }
            else if (strcmp(URL, "/Linux") == 0){ SetContent("Did someone say Linux?", "Linux.Skill"); }
            else if (strcmp(URL, "/Tools") == 0){ SetContent("Common Tools I've used", "Tools.Skill"); }
            else if (strcmp(URL, "/Dev") == 0){ SetContent("Did someone say Development?", "Dev.Skill"); }
            else if (strcmp(URL, "/Linux/Servers") == 0){ SetContent("The most popular server OS", "Servers.Linux"); }
            else if (strcmp(URL, "/Linux/Desktop") == 0){ SetContent("Year of the Linux Desktop?", "Desktop.Linux"); }
            else if (strcmp(URL, "/Linux/Salt") == 0){ SetContent("Centralized System Management", "SaltStack.Linux"); }
            else if (strcmp(URL, "/Linux/Containers") == 0){ SetContent("There's more than just Docker", "Containers.Linux"); }
            else if (strcmp(URL, "/Linux/Virtualization") == 0){ SetContent("VT-x anyone?", "Virtualization.Linux"); }
            else if (strcmp(URL, "/Hobbies") == 0){ SetContent("I like more than Linux; I swear!", "Hobbies.Page"); }
            else if (strcmp(URL, "/Aspirations") == 0){ SetContent("Where do I see myself in 5 years?", "Aspirations.Page"); }
            else if (strcmp(URL, "/test") == 0){ DoTest(); }
            else if (strcmp(URL, "/__halt") == 0){ return; }
            else{ SetTo("Route Not Found", 2); }
        }
        SetTimer(); // To ensure the browser tab doesn't hang, set timer mode back.
    }
}
