(function () {
    var root = $.GetContextPanel();
    var panel = $.CreatePanel("Panel", root, "RoundStatusRoot");
    panel.BLoadLayout("file://{resources}/layout/custom_game/round_status.xml", false, false);
})();
