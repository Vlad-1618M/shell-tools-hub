#!/bin/bash
# ===============================================================================
# Script Name: good_old_days.sh
#
# NOTE: A fun script to remember the internet chaos of the late 90s / early 2000s.
#
# Description:
#       - Finds and displays a write-up about "E-Bombs".
#       - Searches for `ebom.txt` if not found in `$HOME`.
#       - If missing, it will create the file automatically.
#
# ===============================================================================

# Define the expected file path
# file="$HOME/ebom.txt"

# If the file doesn't exist, try searching for it
if [[ ! -f "$file" ]]; then
    echo -e "🔍 Searching for ebom.txt..."
    found_file=$(find "$HOME" -type f -name "ebom.txt" 2>/dev/null | head -n 1)
    
    if [[ -n "$found_file" ]]; then
        file="$found_file"
        echo -e "Found: $file"
    else
        echo -e "ebom.txt not found. Creating it..."
        file="$HOME/ebom.txt"
        cat > "$file" <<EOL

# ===============================================================================
# THE "E-BOMB" - INTERNET CHAOS FROM THE LATE 90s / EARLY 2000s :))
# ===============================================================================

Ah, the **E-Bomb**—not the electromagnetic pulse weapon, but the **browser-crashing nightmare** of the early internet

### 🔹 What Was an "E-Bomb" Online?
- A **browser attack** that **flooded users with infinite pop-up windows**.
- Could **crash computers** by eating up RAM & CPU.
- Often **used on prank sites, warez pages, or shady forums**.
- Usually executed with **JavaScript, VBScript, or ActiveX exploits**.
- **Some versions were unkillable**—closing one window would spawn more.

------------------------------------------------------------------------------------------------------------------

### --> Notorious E-Bomb Variants
 **JavaScript "Loop Bomb"**
\`\`\`html
<script>
    while (true) {
        window.open('https://victimsite.com');
    }
</script>
\`\`\`
--> This script **kept spawning** pop-ups until the browser crashed.

 **"You Can't Close This" Bomb**
\`\`\`html
<script>
    function annoying() {
        setTimeout("window.open('https://victimsite.com');", 1);
    }
    annoying();
</script>
\`\`\`

 **Fake "Windows Error" Loop**
- Some prank sites **simulated a Windows BSOD (Blue Screen of Death)** inside pop-ups.

 **Internet Explorer Exploits (ActiveX + VBScript)**
- Early **IE versions (4–6)** had weak security, allowing rogue sites to **launch infinite pop-ups**, modify system settings, or even trigger **fake shutdowns**.

------------------------------------------------------------------------------------------------------------------

### --> How Did People Stop It?
- **Task Manager (\`CTRL+ALT+DEL\`) → Kill Browser Process**
- ** Hold \`ALT+F4\` like a madman** :))
- ** Disable JavaScript (Netscape/IE Security Settings)**
- ** Ad-blockers (once they became a thing)**
- ** Pop-up blockers** (later added in browsers like Firefox & Chrome)

------------------------------------------------------------------------------------------------------------------

### --> Why Was It Called an "E-Bomb"?
- Similar to a **DDoS attack**, but instead of crashing servers, it **crashed individual browsers**.
- Felt like **a "bomb" going off on your screen**—chaos, overload, and system lag.
- We used it as an internet trolling aka warfare in early online days ... :)) 

------------------------------------------------------------------------------------------------------------------

### --> The Modern Equivalent?
Today’s version of an E-Bomb could be ...
- **  "Notification spam"      [ websites forcing constant browser notifications ]
- **  Infinite redirect loops  [ some phishing/malware sites                     ]
- **  Fake captchas/pop-up ads [ forcing interaction.                            ]

.. but, what do I know.. I am just a dude with a fancy laptop nowadays ¯\_(ツ)_/¯ 

------------------------------------------------------------------------------------------------------------------

### --> WERE YOU A VICTIM OR A PRANKSTER ? 
Did you ever get hit with an E-Bomb, or maybe you were *- the one -* sending links to unsuspecting friends .. :))  
    .... thankfully, computers are stronger now, and this is just a fun shell script memory :))

EOL
        echo -e "Created new ebom.txt at: $file"
    fi
fi

# ... show  content
echo -e "\nRemember the good old days? :0))\n"
sleep 2
cat "$file"