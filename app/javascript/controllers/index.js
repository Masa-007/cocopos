import { Application } from "@hotwired/stimulus";
import SeasonController from "./season_controller";
import CalendarTooltipController from "./calendar_tooltip_controller";
import ShareController from "./share_controller"; 
import SlideshowController from "./slideshow_controller";

const application = Application.start();

application.register("season", SeasonController);
application.register("calendar-tooltip", CalendarTooltipController);
application.register("share", ShareController);
application.register("slideshow", SlideshowController); 
