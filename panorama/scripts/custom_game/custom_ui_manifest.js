(function () {
    function mountRoundPanel() {
        var context = $.GetContextPanel();
        var hudRoot = context.GetParent() && context.GetParent().GetParent() && context.GetParent().GetParent().GetParent();
        if (!hudRoot) {
            $.Schedule(0.2, mountRoundPanel);
            return;
        }

        var hudElements = hudRoot.FindChildTraverse("HUDElements");
        if (!hudElements) {
            $.Schedule(0.2, mountRoundPanel);
            return;
        }

        if (hudElements.FindChildTraverse("RoundStatusRoot")) {
            return;
        }

        var panel = $.CreatePanel("Panel", hudElements, "RoundStatusRoot");
        panel.hittest = false;
        panel.BLoadLayout("file://{resources}/layout/custom_game/round_status.xml", false, false);
    }

    mountRoundPanel();
})();