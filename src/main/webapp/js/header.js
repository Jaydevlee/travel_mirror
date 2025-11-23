document.getElementById("menu_bar").onclick = function() {
    document.getElementById("side_menu").classList.add("active");
    document.getElementById("menu_overlay").classList.add("active");
};

document.getElementById("menu_overlay").onclick = function() {
    document.getElementById("side_menu").classList.remove("active");
    document.getElementById("menu_overlay").classList.remove("active");
};