var App = {
         rotateColor:function(color){var index = (_.indexOf(App.Colors,color) + 1) % (App.Colors.length);var color = App.Colors[index];return(color);},
         statesByColor:function(color){return _.filter(App.States,function(state){return state.fill==color;})},
         voteByColor:function(color){
            var memo = 0;
            App.statesByColor(color).forEach(function(state){memo +=state.value;});
            return memo;
            },
         getState:function(id){return _.find(App.States,function(item){return item.id == id})},
         select:function(evt){
            var id = evt.target.id;
            var state = App.getState(id);
            newFill = App.rotateColor(state.fill);
            var path = document.getElementById(id);
            path.style.fill = newFill;    
            state.fill = newFill;
            state.party = App.PartyNames[_.indexOf(App.Colors,newFill)];
            var title = path.getElementsByTagNameNS("http://www.w3.org/2000/svg","title").item(0);
            title.textContent = state.label + ": "+state.value+" Votes"+((state.party&&state.party != "none")?" for "+state.party+".":".");
            
            for (index=1;index<App.Colors.length;index++){
               var color = App.Colors[index];
               document.getElementById("party_"+index).textContent = App.voteByColor(color);
               }
            },
        init:function(){
            var http = new XMLHttpRequest();
            http.open("GET","ElectoralMapData.json",true);
            http.onload = function(evt){    
               var jsonText = http.responseText;
               var data = JSON.parse(jsonText);
               App.States = data.States;
               App.Colors = data.Colors;
               App.PartyNames = data.PartyNames;
               var legend = document.getElementById("legend");
               var index =0;
               App.PartyNames.forEach(function(partyName){
                  if (index != 0){
                     var label = document.createElementNS("http://www.w3.org/2000/svg","text");
                     label.setAttribute("x",0);
                     label.setAttribute("y",index * 50);
                     label.setAttribute("class","partyLabel");
                     label.setAttribute("fill",App.Colors[index]);
                     label.textContent = partyName;
                     legend.appendChild(label);
                     var label = document.createElementNS("http://www.w3.org/2000/svg","text");
                     label.setAttribute("x",0);
                     label.setAttribute("y",27 + index * 50);
                     label.setAttribute("class","partyVote");
                     label.setAttribute("fill",App.Colors[index]);
                     label.setAttribute("id","party_"+index);
                     label.textContent = "0";
                     legend.appendChild(label);
                  }
                  index++;
               });
            App.States.forEach(function(state){
               var path = document.getElementById(state.id);
               path.style.fill = state.fill;
               var title = document.createElementNS("http://www.w3.org/2000/svg","title");
               title.textContent = state.label + ": "+state.value+" Votes"+(state.party?" for "+state.party+".":".");
               path.appendChild(title);
               for (index=1;index<App.Colors.length;index++){
                  var color = App.Colors[index];
                  document.getElementById("party_"+index).textContent = App.voteByColor(color);
                  }
               })         
            };
            http.onloadend = function(evt){
                if (http.status != 200){
                    alert(http.status+": "+http.statusText);
                    }
                };
            http.send();
            }
      };
      
window.onload = App.init;      
