using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Configuration;
using System.Web.Mvc;
using ItsApp.Models;

namespace ItsApp.Controllers
{
    public class AppConfigController : Controller
    {
        //
        // GET: /AppConfig/

        public ActionResult Config()
        {
            var model = new ConfigModel
            {
                ServiceHost = WebConfigurationManager.AppSettings["ServiceHost"],
                Version = WebConfigurationManager.AppSettings["Version"],
                Env = WebConfigurationManager.AppSettings["Env"]
            };

            return PartialView(model);
        }

        public ActionResult Manifest()
        {
            var model = new ManifestModel
            {
                Date = WebConfigurationManager.AppSettings["Env"] == "debug" ? System.DateTime.Now : new System.DateTime(),

                Version = WebConfigurationManager.AppSettings["Version"]
            }; 

            return View(model);
        }
    }
}
