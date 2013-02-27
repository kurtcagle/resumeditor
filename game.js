function spawn(baseObj,extendedObj){
    var obj = new Object();
    for (key in baseObj) {obj[key] = baseObj[key]};
    if (extendedObj){
        for (key in extendedObj){
            obj[key]=extendedObj[key]
            }
        }
    return obj;
    };
    
function describe(obj){
    var buf = [];
    for (key in obj){buf.push(key)}
    alert(buf.join(", "));
    };
    
function $(label){
    return document.getElementById(label);
    };
    
window.addEventListener("load",function(){
var App = {
    GameActive:false,
    Space:{
        sprite:$("space"),
        wrap:function(obj){
            var borderBBox = obj.sprite.getBBox();
            var spaceBBox = this.sprite.getBBox();
            obj.x = (obj.x &lt; - borderBBox.width)?obj.x + spaceBBox.width:(obj.x &gt; spaceBBox.width + borderBBox.width)?obj.x - (spaceBBox.width + borderBBox.width):obj.x;
            obj.y = (obj.y &lt; - borderBBox.height)?obj.y + spaceBBox.height+ borderBBox.height:(obj.y &gt; spaceBBox.height + borderBBox.height) ? obj.y - (spaceBBox.height + borderBBox.height):obj.y;        
            }
        },
    PowerupTypes:[
        {fill:"blue",name:"Trilithium Crystals",
            oncaptured:function(){
                    App.Ship.fuel += 250;
                    App.Ship.wealth += 50;
                    App.Status.setMessage("Trilithium Crystals boost fuel and shields.");               
                    },
              ondestroyed:function(){
                    App.Status.setMessage("Ouch! Trilithium Crystals Destroyed!");
                    }
                },
        {fill:"lightBlue",name:"Denebian Spice Seeds",
            oncaptured:function(){
                    App.Ship.fuel += 50;                    
                    App.Ship.wealth += 200;
                    App.Status.setMessage("Invaluable Denebian Spice Retrieved!")
                    },
              ondestroyed:function() {
                    App.Status.setMessage("Denebian Spice Destroyed ... awww.!");
                    }
               },
        {fill:"green",name:"Antigrav Shields Boost",
              oncaptured:function(){
                    App.Ship.shieldStrength += 100;
                    App.Ship.wealth += 50;
                    App.Status.setMessage("Antigrav Shields booster enabled.");
                    },
               ondestroyed:function(){
                    App.Status.setMessage("Antigrav Boosters Incinerated. Idiot.");
                    }
               },
        {fill:"white",name:"Repair Kit",
            oncaptured:function(){
                    App.Ship.structuralIntegrity += 150;
                    App.Ship.wealth += 50;
                    App.Status.setMessage("Repairs made to ship.");
                    },
               ondestroyed:function(){
                    App.Status.setMessage("Repair station is now glowing dust.");
                    }
                },
        {fill:"yellow",name:"Systems Virus",
             oncaptured:function(){
                    App.Ship.shieldStrength -= 100;
                    App.Ship.structuralIntegrity -= 100;
                    App.Ship.wealth -= 50;
                    App.Status.setMessage("Systems virus plays havoc on ship.");
                    },
               ondestroyed:function(){
                    App.Ship.wealth += 100;
                    App.Status.setMessage("Successfully destroyed systems virus.");
                    }
                },
        {fill:"red",name:"Berylium Shield Mine",
            oncaptured:function(){
                    App.Ship.fuel -= 50;
                    if (App.Ship.shields){
                        App.Ship.shieldStrength-= -150;
                        }
                     else {
                        App.Ship.structuralIntegrity-= -150;                     
                        }
                    App.Ship.wealth -= 50;
                    App.Status.setMessage("Berylium Shield Mine saps shields.");
                    },
               ondestroyed:function(){
                    App.Ship.wealth += 100;
                    App.Status.setMessage("Successfully destroyed Berylium Shield Mine.");
                    }
                },
        {fill:"maroon",name:"Blackest Hole",
             oncaptured:function(){
                    if (App.Ship.shields) {
                        App.Ship.shieldStrength -= 200;
                        }
                    else {
                        App.Ship.structuralIntegrity -= 200;                    
                        }
                    App.Ship.fuel -= 100;
                    App.Status.setMessage("Blackest Hole sucks.");
                    },
               ondestroyed:function(){
                    App.Ship.wealth += 200;
                    App.Status.setMessage("Successfully destroyed Blackest Hole.");
                    }
                },
        {fill:"orange",name:"Megabomb",
            oncaptured:function(){
                    if (App.Ship.shields) {
                        App.Ship.shieldStrength -= 500;
                        }
                    else {
                        App.Ship.structuralIntegrity -= 500;                    
                        }
                    App.Ship.fuel -= 300;
                    App.Status.setMessage("Megabomb damaged your ship.");
                    },
               ondestroyed:function(){
                    App.Ship.wealth += 400;
                    App.Status.setMessage("Successfully destroyed Megabomb.");
                    }
                },
        {color:"brown",name:"Minibomb",
            oncaptured:function(){
                    if (App.Ship.shields) {
                        App.Ship.shieldStrength -= 250;
                        }
                    else {
                        App.Ship.structuralIntegrity -= 250;                    
                        }
                    App.Ship.fuel -= 150;
                    App.Status.setMessage("Minibomb damaged your ship.");
                    },
               ondestroyed:function(){
                    App.Ship.wealth += 200;
                    App.Status.setMessage("Successfully destroyed Minibomb.");
                    }
                },
        {fill:"url(#randomGrad)",name:"Wormhole",
            oncaptured:function(){
                    App.Ship.angle = 5 * Math.floor(72 * Math.random());
                    App.Ship.x = Math.floor(640 * Math.random());
                    App.Ship.y = Math.floor(480 * Math.random());
                    App.Status.setMessage("You went through a wormhole.");
                    },
               ondestroyed:function(){
                    App.Status.setMessage("Wormhole destroyed.");
                    }
                }
        ],
    PowerupKey:null,
    Animator:{
        queue:[],
        add:function(){
            var obj = [];
            for (var index = 0;index&lt;arguments.length;index++){obj.push(arguments[index]);}
            var queue = this.queue;
            obj.forEach(function(item){queue.push(item)});
            },
        remove:function(obj){
            var buf = [];
            for (var key in this.queue){if (!(this.queue[key]== obj)){buf.push(this.queue[key])}};
            this.queue = buf;
            },
        start:function(){
            App.Animator.queue.forEach(function(obj){obj.onstart()});
            App.Animator.queue.forEach(function(obj){
                var updateKey = setInterval(function(){obj.onupdate()},(obj.interval?obj.interval:50));
                obj.updateKey = updateKey;
                });
            },
        update:function(obj){
            App.Animator.queue.forEach(function(obj){
                if (obj.updateKey == null) {obj.onstart()};
                if (obj.updateKey == null){
                   var updateKey = setInterval(function(){obj.onupdate()},(obj.interval?obj.interval:50));
                   obj.updateKey = updateKey;
                   }
                });
            },
        stop:function(obj){
                obj.onstop();
                this.remove(obj);            
                clearInterval(obj.updateKey);
            },
        endGame:function(){
            App.Animator.queue.forEach(function(obj){
                App.Animator.stop(obj);
                });
            App.Status.setMessage("Game Over");
            clearInterval(App.PowerupKey);
            App.GameActive=false;
            document.location.href="game.svg";
            }
        },
    KeyControl:{
        field:null,
        keyMap:{},
        init:function(keyMap){
            this.keyMap = keyMap;
            this.field = $("keyInput");
            this.field.addEventListener("keydown",function(evt){
                if (App.KeyControl.keyMap[evt.keyCode] != null){
                    App.KeyControl.keyMap[evt.keyCode]();
                    }
                else {
                    App.Status.setMessage("Keypress = "+evt.keyCode);
                    }
                });
             this.field.focus();
             this.field.onblur=function(){
                this.focus()};
            }
        },
    Ship: {
        type:"ship",
        sprite:null,
        spriteFrame:null,
        spriteShields:null,
        interval:50,
        angle:0,
        x:320,
        y:240,
        vx:0,
        vy:0,
        acc:0,
        shields:false,
        shieldStrength:1000,
        fuel:1000,
        structuralIntegrity:1000,
        countDown:100,
        wealth:0,
        rotate:function(angle){
            this.angle = (this.angle + angle) % 360;
            if (this.angle &lt;0){this.angle += 360;}
            },
        accelerate:function(value){
            if (App.Ship.fuel &gt; 0){
                if (value != 0)
                    {this.acc += value;}
                else
                    {this.acc = 0;}
                if (this.acc != 0) {
                    if (this.acc &gt;0) {
                        $("capBaseColor").setAttribute("stop-color","yellow");
                        }
                    else {
                        $("capBaseColor").setAttribute("stop-color","red");                
                        }
                    }
                else {
                    $("capBaseColor").setAttribute("stop-color","blue");            
                    }
                }
            },
        hardStop:function(){
            this.fuel -= Math.pow(20 * Math.abs(this.acc),2) + Math.abs(this.vx)+Math.abs(this.vy);
            this.fuel = Math.max(this.fuel,0);
            this.structuralIntegrity -= Math.pow(this.acc * 20,2);
            this.acc = 0;
            this.vx = 0;
            this.vy =0;
            $("capBaseColor").setAttribute("stop-color","blue");            
            },
        shieldsFlip:function(){
            this.shields = !this.shields;
            },
        onstart:function(){
            this.sprite = $("ship");
            this.spriteFrame = $("ship-frame");
            this.spriteShields= $("shields");
            },
        onupdate:function(){
            this.vx += this.acc * Math.sin(this.angle * 3.1415927 /180);
            this.vy += -this.acc * Math.cos(this.angle * 3.1415927 /180);
            this.x += this.vx;
            this.y += this.vy;
            App.Space.wrap(this);
            this.fuel -= Math.abs(this.acc);
            this.structuralIntegrity = Math.min(this.structuralIntegrity,1000);
            this.shieldStrength = Math.min(this.shieldStrength,1500);
            if (this.shieldStrength &lt;= 0){
                this.shieldStrength = 0;
                this.shields = false;
                }
            this.fuel = Math.max(Math.min(this.fuel,2000),0);
            if (this.fuel == 0 &amp;&amp; this.shieldStrength &gt; 0){
                this.fuel = this.shieldStrength;
                this.shieldStrength = 0;                
                }
            this.sprite.setAttribute("transform","rotate("+this.angle+")");
            this.spriteFrame.setAttribute("transform","translate("+this.x+","+this.y+")");
            this.spriteShields.setAttribute("visibility",this.shields?"visible":"hidden");
            if (this.shields){this.fuel-= 0.1};
            if (this.structuralIntegrity &lt;0){
                App.Status.setMessage("Core Breach! Game Over!");
                this.sprite.setAttributeNS("http://www.w3.org/1999/xlink","href","#explosion");
                this.countDown--;
                this.sprite.setAttribute("opacity",this.countDown/100);
                if (this.countDown == 0){
                    App.Animator.endGame();
                
                    }
                }
            },
        onstop:function(){
            }
        },
    FuelGauge:{
        sprite:null,
        label:null,
        text:null,
        bar:null,
        back:null,
        onstart:function(){
            this.sprite = $("fuelGauge")
            this.label = this.sprite.getElementsByClassName("gaugeLabel").item(0);
            this.text = this.sprite.getElementsByClassName("gaugeText").item(0);
            this.bar = this.sprite.getElementsByClassName("gaugeBar").item(0);
            },
        onupdate:function(){
            var value = App.Ship.fuel;
            this.text.textContent = Math.round(value);
            this.bar.setAttribute("width",100 * value/1000);
            var fill = (value&gt;500)?"green":(value&gt;250)?"yellow":"red";
            this.bar.setAttribute("fill",fill);
            },
        onstop:function(){       
            }
        },
    ShieldGauge:{
        sprite:null,
        onstart:function(){
            this.sprite = $("shieldGauge")
            this.label = this.sprite.getElementsByClassName("gaugeLabel").item(0);
            this.text = this.sprite.getElementsByClassName("gaugeText").item(0);
            this.bar = this.sprite.getElementsByClassName("gaugeBar").item(0);
            },
        onupdate:function(){
            var value=App.Ship.shieldStrength;
            this.text.textContent = Math.round(value);
            this.text.textContent = Math.round(value);
            this.bar.setAttribute("width",100 * value/1000);
            var fill = (value&gt;500)?"green":(value&gt;250)?"yellow":"red";
            this.bar.setAttribute("fill",fill);
            },
        onstop:function(){       
            }
        },
    IntegrityGauge:{
        sprite:null,
        onstart:function(){
            this.sprite = $("integrityGauge")
            this.label = this.sprite.getElementsByClassName("gaugeLabel").item(0);
            this.text = this.sprite.getElementsByClassName("gaugeText").item(0);
            this.bar = this.sprite.getElementsByClassName("gaugeBar").item(0);
            },
        onupdate:function(){
            var value=App.Ship.structuralIntegrity;
            this.text.textContent = Math.round(value);
            this.text.textContent = Math.round(value);
            this.bar.setAttribute("width",100 * value/1000);
            var fill = (value&gt;500)?"green":(value&gt;250)?"yellow":"red";
            this.bar.setAttribute("fill",fill);
            },
        onstop:function(){       
            }
        },
    Status:{
        sprite:null,
        message:"Test",
        setMessage:function(msg){
            this.message = msg;
            },
        onstart:function(){
            this.sprite = $("status")
            },
        onupdate:function(){
            this.sprite.textContent = this.message;
            },
        onstop:function(){
            }
        },
    WealthGauge:{
        sprite:null,
        onstart:function(){
            this.sprite = $("wealthGauge")
            },
        onupdate:function(){
            this.sprite.textContent = Math.round(App.Ship.wealth);
            },
        onstop:function(){       
            }
        },
    Missile: {
        type:"missile",
        sprite:null,
        spriteFrame:null,
        interval:25,
        x:320,
        y:240,
        duration:100,
        v:0,
        onstart:function(){
            this.x = App.Ship.x;
            this.y = App.Ship.y;
            this.v = 5;
            this.vx = App.Ship.vx + this.v * Math.sin(App.Ship.angle * 3.1415927 /180);
            this.vy = App.Ship.vy - this.v * Math.cos(App.Ship.angle * 3.1415927 /180);
            },
        onupdate:function(){
            this.x += this.vx;
            this.y += this.vy;
            App.Space.wrap(this);
            this.sprite.setAttribute("x",this.x);
            this.sprite.setAttribute("y",this.y);
            this.duration--;
            if (this.duration == 0){
                App.Animator.stop(this);
                }
            },
        onstop:function(){
            App.Missiles.missileArray = App.Missiles.missileArray.filter(function(obj){return !(obj == this)})
            $("missiles").removeChild(this.sprite);
            }
        },
    Missiles:{
        missileArray:[],
        fire:function(){
            if (App.Ship.fuel &gt; 0){
                var sprite = document.createElementNS("http://www.w3.org/2000/svg","use");
                sprite.setAttributeNS("http://www.w3.org/1999/xlink","href","#missile-template");
                $("missiles").appendChild(sprite);
                sprite.setAttribute("x",App.Ship.x);
                sprite.setAttribute("y",App.Ship.y);
                var missile = spawn(App.Missile,{sprite:sprite});
                App.Animator.add(missile);
                App.Animator.update(missile);
                this.missileArray.push(missile);
                App.Ship.fuel -= 5;
                App.Ship.fuel = Math.max(App.Ship.fuel,0);
                }
            }
        },
    Powerup: {
        type:"powerup",
        sprite:null,
        spriteFrame:null,
        interval:50,
        duration:1000,
        x:0,
        y:0,
        vx:0,
        vy:0,
        power:"",
        color:"",
        powerName:"",
        duration:1000,
        onstart:function(){
            this.x = 320+Math.round(Math.random()*639 - 320);
            this.y = 240+Math.round(Math.random()*479 - 240),
            this.vx = Math.random()*5 - 2;
            this.vy = Math.random()*5 - 2;
            var index = Math.floor(Math.random()*App.PowerupTypes.length)
            this.powerupData = App.PowerupTypes[index];
            this.sprite.setAttribute("fill",this.powerupData.fill);
            this.sprite.setAttributeNS("http://www.w3.org/1999/xlink","href",this.powerupData.href?"#"+this.powerupData.href:"#powerup-template");            
            },
        onupdate:function(){
            this.x += this.vx;
            this.y += this.vy;
            App.Space.wrap(this);
            this.sprite.setAttribute("x",this.x);
            this.sprite.setAttribute("y",this.y);
            if (this.duration == 0){
                App.Animator.stop(this);
                }
            var powerup = this;
            if (Math.sqrt(Math.pow(powerup.x - App.Ship.x,2)+Math.pow(powerup.y - App.Ship.y,2))&lt;45){
                powerup.powerupData.oncaptured();    
                App.Animator.stop(powerup);
                };
            var destroyedflag = false;
            App.Missiles.missileArray.forEach(function(missile){
                if (!destroyedflag){
                    if (Math.sqrt(Math.pow(powerup.x - missile.x,2)+Math.pow(powerup.y - missile.y,2))&lt;10){
                        powerup.sprite.setAttributeNS("http://www.w3.org/1999/xlink","href","#dying-powerup-template");
                        App.Animator.stop(missile);
                        destroyedFlag = true;
                        App.Animator.stop(powerup);
                        powerup.powerupData.ondestroyed();
                        };
                    }
                })
            this.duration--;
            if (this.duration == 0){
                App.Animator.stop(this);
                }
            },
            onstop:function(){
                $("powerups").removeChild(this.sprite);
            }
        },
    Powerups:{
        powerupArray:[],
        launch:function(){
            var sprite = document.createElementNS("http://www.w3.org/2000/svg","use");
            sprite.setAttributeNS("http://www.w3.org/1999/xlink","href","#powerup-template");
            $("powerups").appendChild(sprite);
            var powerup = spawn(App.Powerup,{sprite:sprite});
            App.Animator.add(powerup);
            App.Animator.update(powerup);
            }
        },
    Init:function(){
        if (!App.GameActive){
        App.GameActive = true;
        var keyMap = {
             12:function(){
                App.Ship.accelerate(0);
                },
            32:function(){
                App.Missiles.fire();
                },
            36:function(){
                App.Ship.accelerate(0);
                },
            37:function(){
                App.Ship.rotate(-5);
                },
            38:function(){
                App.Ship.accelerate(.05);
                },
            39:function(){
                App.Ship.rotate(5);
                },            
            40:function(){
                App.Ship.accelerate(-.05);
                },
            45:function(){
                App.Ship.hardStop();
                },
             83:function(){
                App.Ship.shieldsFlip();
                },
             190:function(){
                App.Missiles.fire();
                },
             191:function(){
                App.Ship.hardStop();
                }
            };
        
            App.KeyControl.init(keyMap);
            window.App = App;
            App.Animator.add(App.Ship,App.FuelGauge,App.ShieldGauge,App.IntegrityGauge,App.WealthGauge,App.Status);
            App.PowerupKey = setInterval(function(){App.Powerups.launch()},5000);
            App.Animator.start();
            App.Status.setMessage("Welcome, Captain!");
            }
        }
    };
    window.App = App;
    },false);
