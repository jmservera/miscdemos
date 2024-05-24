function hierarchyMenu(steps, changeIndex){
    var hierarchy = [$('<ul>')];
    var currentLevel = 2;
  
    var headings = $('.page-content h2, .page-content h3');
    headings.each(function(i, heading) {
      var level = parseInt(heading.tagName.slice(1));
      var id = $(heading).attr('id');
      var text = $(heading).text();
      var link = $('<a>').attr('href', `#${id}`).text(text);
      
      //TODO: manage hashchange at main level
      $(window).on('hashchange', function(e){      
        if(location.hash==`#${id}`){
            var step;
            if(level==2){
              step=$($(heading).parents('.section')[0]).find('.step:first')[0];
            }
            else{
              step=$(heading).parents('.step')[0];
            }
            let current=steps.index(step);
            changeIndex(current);
        }
      });
  
      var item = $('<li>').append(link);
  
      if (level > currentLevel) {
        var newLevel = $('<ul>');
        // var button = $('<button>').attr('type','button').addClass('collapser').text('+').click(function() {
        //   newLevel.toggle();
        //   button.text(newLevel.is(':visible') ? '-' : '+');
        // });
        hierarchy[hierarchy.length - 1].children().last().addClass('collapser').addClass('uncollapsedMarker');
        hierarchy[hierarchy.length - 1].children().last().append(newLevel);
        hierarchy.push(newLevel);
      } else if (level < currentLevel) {
        hierarchy.pop();
      }
  
      hierarchy[hierarchy.length - 1].append(item);
      currentLevel = level;
    });
  
    $('#sidebar-index').append(hierarchy[0]);
    $('#sidebar-toggle').click(function() {
      $('#sidebar-index').toggleClass('collapsed');
      $('#sidebar-index').hasClass('collapsed') ? $(this).text('<') : $(this).text('>');
    });

    $('#sidebar-index .collapser').on('click', function(event) {
      // This code will run when the caret is clicked
      if (event.target.tagName === 'A') {
        return;
      }
      $(this).children('ul').toggle();
      // Check if the parent li has the class 'collapsedMarker' or 'uncollapsedMarker'
      if ($(this).hasClass('collapsedMarker')) {
        // If it has the class 'collapsedMarker', remove it and add the class 'uncollapsedMarker'
        $(this).removeClass('collapsedMarker').addClass('uncollapsedMarker');
      } else if ($(this).hasClass('uncollapsedMarker')) {
        // If it has the class 'uncollapsedMarker', remove it and add the class 'collapsedMarker'
        $(this).removeClass('uncollapsedMarker').addClass('collapsedMarker');
      }
    });
  }
  

  
  function tutorial(){
    let steps = $('.step');
    let currentIndex = 0;
  
    // Show the first section
    steps[currentIndex].classList.add('active');
    $(steps[currentIndex]).parents('.section')[0].classList.add('active');
  
    let changeIndex= (index)=>{
      $(steps[currentIndex]).parents('.section')[0].classList.remove('active');
      steps[currentIndex].classList.remove('active');
      currentIndex=index;
      steps[currentIndex].classList.add('active');
      $(steps[currentIndex]).parents('.section')[0].classList.add('active');
      if(currentIndex>0){
        $('button.prev').removeAttr('disabled');
      }
      else{
        $('button.prev').attr('disabled','disabled');
      }
      if(currentIndex<steps.length-1){
        $('button.next').removeAttr('disabled');
      }
      else{
        $('button.next').attr('disabled','disabled');
      }
    };
  
    let movePrev=() => {
      if (currentIndex > 0) {
          changeIndex(currentIndex-1);
      }
    };
    let moveNext= () => {
      if (currentIndex < steps.length - 1) {
          changeIndex(currentIndex+1);
        }
    }
  
    $('button.prev').each((i,btn)=>btn.addEventListener('click',movePrev,false));
    $('button.next').each((i,btn)=>btn.addEventListener('click',moveNext,false));
  
    changeIndex(0);
  
    hierarchyMenu(steps,changeIndex);
  }
  
  $(document).ready(function() {
    tutorial();
    //TODO: Fix the issue with the hashchange event
    if(location.hash){
      let oldLoc=location.href;
      window.location=location+"&";
      window.location=oldLoc;
    }
  });