

$(document).ready(
    function()
    {
        var slide = false;
        var slideSpeed = "fast";
    
        function toggle(element)
        {
            if (slide)
            {
                $(element).parent().children(".data").slideToggle(slideSpeed);
            }
            else
            {
                $(element).parent().children(".data").toggle();
            }
        };
        
        $(".hide > .data").hide(); 
        $(".show > .data").show(); 

        $(".hide > a").click(
        function()
        {
            toggle(this);
    
            return false;
        });

        $(".show > a").click(
        function()
        {
            toggle(this);
                
            return false;
        });

        $("#collapseAll").click(
        function()
        {
            if (slide)
            {
                $(".show > .data").slideUp(slideSpeed); 
                $(".hide > .data").slideUp(slideSpeed); 
            }
            else
            {
                $(".show > .data").hide(); 
                $(".hide > .data").hide(); 
            }
            return false;
        });

        $("#expandAll").click(
        function()
        {
            if (slide)
            {
                $(".show > .data").slideDown(slideSpeed); 
                $(".hide > .data").slideDown(slideSpeed); 
            }
            else
            {
                $(".show > .data").show(); 
                $(".hide > .data").show(); 
            }
            return false;
        });

        $("#defaultView").click(
        function()
        {
            if (slide)
            {
                $(".hide > .data").slideUp(slideSpeed); 
                $(".show > .data").slideDown(slideSpeed);
            }
            else
            {
                $(".hide > .data").hide(); 
                $(".show > .data").show(); 
            }
            return false;
        });
    }
);
